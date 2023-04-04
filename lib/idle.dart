import 'package:flutter/material.dart';
import 'main.dart';
import 'calendar.dart';
//import 'recording_button.dart';
import 'simple_recorder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IdleWidget extends StatelessWidget {
  const IdleWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {

    var message = "undefined";
    var localization = AppLocalizations.of(context);
    if (localization != null) {
      message = localization.whatDoYouWantToDo;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CalendarWidget(appState: appState),
        Text(
          message.toString()
        ),
        Text(
          '${appState.counter}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SimpleRecorder(),
        //RecordingButton(appState: appState),
      ],
    );
  }
}

