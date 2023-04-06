import 'package:flutter/material.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'simple_recorder.dart';

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
        CalendarWidget(),
        SimpleRecorderWidget(mode: RecorderWidgetMode.record),
      ],
    );
  }
}

