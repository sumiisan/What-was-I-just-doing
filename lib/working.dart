import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_indicator.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef TimerCallback = void Function();

class WorkingTimer {
  Duration elapsed = const Duration(seconds: 0);

  Duration _duration = Duration(seconds: 0);
  DateTime _startDate = DateTime.now();
  Timer? timer;

  void start(Duration duration, {TimerCallback? onFinish, TimerCallback? onTick}) {
    elapsed = const Duration(seconds: 0);
    _startDate = DateTime.now();
    _duration = duration;
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      elapsed = DateTime.now().difference(_startDate);
      onTick?.call();
      if (elapsed > _duration) {
        cancel();
        if (onFinish != null) onFinish();
      }
    });
  }

  void cancel() {
    timer?.cancel();
  }

}

class WorkingWidget extends StatelessWidget {
  const WorkingWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var ctx = AppLocalizations.of(context);

    var finishMessage = ctx?.finishTask ?? "Finish";
    var abortMessage = ctx?.abortTask ?? "Abort";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(appState.currentTask.name),
        WorkProgressIndicator(appState: appState),
        ElevatedButton(
          onPressed: () {
            appState.finishWork();
          },
          child: Text(finishMessage),
        ),
        ElevatedButton(
          onPressed: () {
            appState.finishWork(isAborted: true);
          },
          child: Text(abortMessage),
        ),
      ],
    );
  }
}