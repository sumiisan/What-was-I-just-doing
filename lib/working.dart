import 'package:flutter/material.dart';
import 'package:what_was_i_just_doing/simple_recorder.dart';
import 'main.dart';

class WorkingWidget extends StatelessWidget {
  const WorkingWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Working',
        ),
        ElevatedButton(
          onPressed: () {
            appState.finishWork();
          },
          child: const Text('Finish'),
        ),
        SimpleRecorderWidget(mode: RecorderWidgetMode.none),
      ],
    );
  }
}