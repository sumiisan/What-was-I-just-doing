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
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:logger/logger.dart';

import 'app_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const theSource = AudioSource.microphone;

class SimpleRecorderWidget extends StatefulWidget {
  const SimpleRecorderWidget({super.key, required RecorderWidgetMode mode}) : this.mode = mode;

  final RecorderWidgetMode mode;

  @override
  Recorder createState() => Recorder(mode: mode);
}

enum RecorderWidgetMode { none, record, playback, confirm }

class Recorder extends State<SimpleRecorderWidget> {
  Recorder({required this.mode});

  final Codec _codec = Codec.pcm16WAV;
  String mediaPath = 'task.wav';
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder(logLevel: Level.error);
  bool _mRecorderIsInited = false;

  RecorderWidgetMode mode;

  @override
  void initState() {
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    
    await _mRecorder!.openRecorder();

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

  Future<void> record() async {
    Logger().log(Level.debug, "Recorder.record() $mediaPath");
    final directory = await getTemporaryDirectory();
    _mRecorder!
        .startRecorder(
      toFile: "${directory.path}/$mediaPath",
      codec: _codec,
      audioSource: theSource,
      numChannels: 1,
      sampleRate: 44100,
      bitRate: 16000,
    )
        .then((value) {
      setState(() {
      });
    });
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
      });
    });
  }

  // Utils

  Future<File> getFileFromAssets(String path) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = "$tempPath/$path";
    var file = File(filePath);
    if (file.existsSync()) {
      return file;
    } else {
      final byteData = await rootBundle.load('assets/$path');
      final buffer = byteData.buffer;
      await file.create(recursive: true);
      return file
          .writeAsBytes(buffer.asUint8List(byteData.offsetInBytes,
          byteData.lengthInBytes));
    }
  }

// ----------------------------- UI --------------------------------------------

  bool isRecording() {
    return !_mRecorder!.isStopped;
  }

  bool isInitialized() {
    return _mRecorderIsInited;
  }

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<AppState>();
    appState.injectRecorder(this);
    
    mediaPath = "${appState.currentTask.id}.wav";

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
      case RecorderWidgetMode.none:
        return Container();

      case RecorderWidgetMode.record:
        return Column(children: [
            Text(_mRecorder!.isRecording ? prompt2 : prompt1),
            ElevatedButton(
              onPressed: appState.recordButtonTapped,
              style: ElevatedButton.styleFrom(
                //backgroundColor: _mRecorder!.isRecording ? const Color.fromARGB(30, 255, 0, 0) : const Color.fromARGB(30, 0, 200, 0),
                minimumSize: const Size(300, 70),
              ),
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
        var isNewTask = appState.currentTask.timeSpent == 0;
        
        return Column(children: [
          Text(confirmText),
          ElevatedButton(
            onPressed: appState.startWork,
            child: Text(proceedCaption),
          ),
          ElevatedButton(
            onPressed: appState.confirmTask,
            child: Text(playCaption),
          ),
          if (isNewTask)
            ElevatedButton(
              onPressed: appState.startRecord,
              child: Text(retakeCaption),
            ),
          if (!isNewTask)
            ElevatedButton(
              onPressed: appState.newTask,
              child: const Text("No"),
            ),
  
          const SizedBox(
            width: 20,
          ),
        ]);
    }

  }
}