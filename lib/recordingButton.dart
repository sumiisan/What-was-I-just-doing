import 'package:flutter/material.dart';
import 'main.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        appState.startRecording();
      },
      child: const Text('Start Recording'),
    );
  }
}
