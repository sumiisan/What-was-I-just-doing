/*
import 'dart:async'
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:intl/date_symbol_data_file.dart';
//import 'package:path/path.dart' as path;


class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  StreamSubscription? _callback;
  String? recordedAudioUrl;
  Duration duration = Duration(milliseconds: 0);

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();

    await _recorder?.openRecorder();
    await _recorder?.setSubscriptionDuration(Duration(milliseconds: 10));
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


  Future<void> startRecording() async {
    if (_isRecording) {
      return;
    }
    _isRecording = true;

    print("init recorder");
    await init();

    print("start recorder");
    await _recorder?.startRecorder(toFile: 'test.wav', codec: Codec.pcm16WAV);

    _callback = _recorder!.onProgress!.listen((e) {
      duration = e.duration;
    });
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }
    _isRecording = false;
    _callback?.cancel();

    recordedAudioUrl = await _recorder?.getRecordURL(path: 'test.wav');
    print("🟠 recorded path= $recordedAudioUrl");

    var size = recordedAudioUrl != null ? await File(recordedAudioUrl!).length() : 0;
    print("🟠 recorded size= $size duration= $duration");

    await _recorder?.closeRecorder();
    return await _recorder?.stopRecorder();
  }
}*/