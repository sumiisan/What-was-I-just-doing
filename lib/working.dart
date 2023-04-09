import 'package:flutter/material.dart';
import 'package:what_was_i_just_doing/simple_recorder.dart';
import 'app_state.dart';
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

    var workingMessage = ctx?.workingOnTask ?? "Working";
    var finishMessage = ctx?.finishTask ?? "Finish";
    var abortMessage = ctx?.abortTask ?? "Abort";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(appState.currentTask.name),
        Text(workingMessage),
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
        const SimpleRecorderWidget(mode: RecorderWidgetMode.none),
      ],
    );
  }
}