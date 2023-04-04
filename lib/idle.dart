import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'calendar.dart';
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
      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Invoke "debug painting" (press "p" in the console, choose the
      // "Toggle Debug Paint" action from the Flutter Inspector in Android
      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      // to see the wireframe for each widget.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CalendarWidget(appState: appState),
        Text(
          message.toString()
          ,
        ),
        Text(
          '${appState.counter}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
