import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class RecordingButton extends StatefulWidget {
  const RecordingButton({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<RecordingButton> createState() => RecordingState();
}

class RecordingState extends State<RecordingButton> {
  FlutterSoundRecorder? _recorder;
  StreamSubscription? _callback;

  bool _isRecording = false;
  String? recordedAudioUrl;
  String watchText = "aaa";
  Duration recordDuration = const Duration(milliseconds: 0);

  Future<void> init() async {
    print("🟠 init recording state obj");
    _recorder = FlutterSoundRecorder();
    await _recorder?.openRecorder();
    await _recorder?.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.denied) {
      // パーミッションが拒否された場合の処理
    } else if (status == PermissionStatus.granted) {
      // パーミッションが許可された場合の処理
    } else if (status == PermissionStatus.permanentlyDenied) {
      // パーミッションが完全に拒否された場合の処理
    }
  }

  void startPressed() {
    setState(() {
      _isRecording = true;
      watchText = "recording...";
    });

    startRecording();
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      return;
    }

    await requestMicrophonePermission();

    print("init recorder");
    await init();

    print("start recorder");
    await _recorder?.startRecorder(toFile: 'test.wav', codec: Codec.pcm16WAV);

    _callback = _recorder!.onProgress!.listen((e) {
      recordDuration = e.duration;
    });
  }

  void stopPressed() {
    stopRecording();
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    setState(() {
      _isRecording = false;
      watchText = "stopped";
    });
    _callback?.cancel();

    recordedAudioUrl = await _recorder?.getRecordURL(path: 'test.wav');
    print("🟠 recorded path= $recordedAudioUrl");

    var size = recordedAudioUrl != null ? await File(recordedAudioUrl!).length() : 0;
    print("🟠 recorded size= $size duration= $recordDuration");

    await _recorder?.closeRecorder();
    await _recorder?.stopRecorder();

    AppState appState = widget.appState;

    appState.recordingEnded(recordedAudioUrl);
    return null;
  }

  @override
  Widget build(BuildContext context) {

    if (_isRecording) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () {
              stopPressed();
            },
            child: const Text('Stop Recording'),
          ),
          Text("$recordDuration sec."),
        ],
      );
    } else {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () {
              startPressed();
            },
            child: const Text('Start Recording'),
          ),
          Text(watchText),
        ],
      );
    }
  }
}