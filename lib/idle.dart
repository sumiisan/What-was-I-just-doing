import 'package:flutter/material.dart';
import 'app_state.dart';
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
    var ctx = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SimpleRecorderWidget(appState),
        ElevatedButton(
          onPressed: (){ 
            appState.openTaskList();
          }, 
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          child: Text(ctx?.openTaskList ?? "past tasks")
        ),
      ],
    );
  }
}

