import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  AudioRecorder() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      return;
    }
    _isRecording = true;
    await _recorder!.openRecorder();
    await _recorder!.startRecorder(toFile: 'test.wav');
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }
    _isRecording = false;
    await _recorder!.stopRecorder();
    await _recorder!.closeRecorder();
  }
}