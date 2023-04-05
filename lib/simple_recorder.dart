/*
 * This file was originally part of Flutter-Sound. (simple_recorder.dart)
 * and was modified heavily by sumiisan to fit the needs of this (what was I just doing) project.
 *
 * original:
 * 
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'package:provider/provider.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///
typedef _Fn = void Function();

const theSource = AudioSource.microphone;

class SimpleRecorderWidget extends StatefulWidget {
  const SimpleRecorderWidget({super.key});

  @override
  Recorder createState() => Recorder();
}

enum RecorderWidgetMode { record, playback, confirm }

class Recorder extends State<SimpleRecorderWidget> {
  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  bool _playing = false;
  _Fn onPlayEnded = () {};

  RecorderWidgetMode mode = RecorderWidgetMode.record;

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {
                _playing = false;
              });
              onPlayEnded();
            })
        .then((value) {
      setState(() {
        _playing = true;
      });
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  bool isRecording() {
    return !_mRecorder!.isStopped;
  }

  bool isInitialized() {
    return _mRecorderIsInited && _mPlayerIsInited;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<AppState>();
    appState.injectRecorder(this);

    var ctx = AppLocalizations.of(context);

    var prompt1 = ctx?.whatDoYouWantToDo ?? "[missing]";
    var prompt2 = ctx?.sayNextActivity ?? "[missing]";

    var recordCaption = ctx?.recordNextActivity ?? "[missing]";
    var endRecordCaption = ctx?.endRecording ?? "[missing]";
    var recordingCaption = ctx?.recordingInProgress ?? "[missing]";

    var playbackCaption = ctx?.playRecording ?? "[missing]";
    var playCaption = ctx?.listenAgain ?? "[missing]";
    var stopPlayCaption = ctx?.stopPlayback ?? "[missing]";
    var confirmText = ctx?.confirmText ?? "[missing]";
    var proceedCaption = ctx?.proceed ?? "[missing]";
    var retakeCaption = ctx?.recordAgain ?? "[missing]";

    switch (mode) {
      case RecorderWidgetMode.record:
        return Column(children: [
            Text(_mRecorder!.isRecording ? prompt2 : prompt1),
            ElevatedButton(
              onPressed: appState.recordButtonTapped,
              child: Text(_mRecorder!.isRecording ? endRecordCaption : recordCaption),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(_mRecorder!.isRecording
                ? recordingCaption
                : ''),
          ]);

      case RecorderWidgetMode.playback:
        return Column(children: [
          Text(playbackCaption),
        ]);

      case RecorderWidgetMode.confirm:
        return Column(children: [
          Text(confirmText),
          ElevatedButton(
            onPressed: appState.recordingEnded,
            child: Text(proceedCaption),
          ),
          ElevatedButton(
            onPressed: appState.confirmRecord,
            child: Text(_mPlayer!.isPlaying ? stopPlayCaption : playCaption),
          ),
          ElevatedButton(
            onPressed: appState.startRecord,
            child: Text(retakeCaption),
          ),
          const SizedBox(
            width: 20,
          ),
          Text(_mPlayer!.isPlaying
              ? 'Playing'
              : ''),
        ]);
    }

  }
}