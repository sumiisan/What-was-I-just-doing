
import 'package:flutter/material.dart';
import 'task.dart';

import 'app_state.dart';
import 'progress_indicator.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
        Text(ctx?.startDate ?? "Start date", textScaleFactor: 0.7,),
        TaskNameLabel(task: appState.currentTask),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
            onPressed: appState.fasterNotificationFrequency, 
            child: Text(ctx?.faster ?? "Faster")
          ),
          SizedBox(width: 120, 
            child: WorkProgressIndicator(appState: appState)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
            onPressed: appState.slowerNotificationFrequency, 
            child: Text(ctx?.slower ?? "Slower")
          ),
        ],),
        
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

