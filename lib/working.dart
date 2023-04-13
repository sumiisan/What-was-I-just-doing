import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'progress_indicator.dart';
import 'task.dart';
import 'app_state.dart';


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

    var thinBorderStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.normal,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(ctx?.startDate ?? "Start date", textScaleFactor: 0.7,),
        TaskNameLabel(task: appState.currentTask),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          OutlinedButton(
            onPressed: appState.fasterNotificationFrequency,
            style: thinBorderStyle, 
            child: Text(ctx?.faster ?? "Faster")
          ),
          SizedBox(width: 120, 
            child: WorkProgressIndicator(appState: appState)
          ),
          OutlinedButton(
            onPressed: appState.slowerNotificationFrequency, 
            style: thinBorderStyle, 
            child: Text(ctx?.slower ?? "Slower")
          ),
        ],),
        
        OutlinedButton(
          onPressed: () {
            appState.finishWork();
          },
          child: Text(finishMessage),
        ),
        OutlinedButton(
          onPressed: () {
            appState.finishWork(isAborted: true);
          },
          child: Text(abortMessage),
        ),
      ],
    );
  }
}

