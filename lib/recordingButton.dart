import 'package:flutter/material.dart';
import 'main.dart';
import 'recorder.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {

    if (appState.isRecording) {
      return ElevatedButton(
        onPressed: () {
          appState.stopRecording();
        },
        child: const Text('Stop Recording'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          appState.startRecording();
        },
        child: const Text('Start Recording'),
      );
    }
    
  }
}
