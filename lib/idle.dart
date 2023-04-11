import 'package:flutter/material.dart';
import 'app_state.dart';
import 'simple_recorder.dart';
import 'task_list.dart';

class IdleWidget extends StatelessWidget {
  const IdleWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SimpleRecorderWidget(mode: RecorderWidgetMode.record),
        TaskListWidget(appState: appState),

      ],
    );
  }
}

