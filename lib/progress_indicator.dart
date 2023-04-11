import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_state.dart';

class WorkProgressIndicator extends StatefulWidget {
  const WorkProgressIndicator({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WorkProgressIndicator> createState() => _WorkProgressIndicatorState();
}

class _WorkProgressIndicatorState extends State<WorkProgressIndicator> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ctx = AppLocalizations.of(context);

    var workingMessage = ctx?.workingOnTask ?? "Working";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 25),
        SizedBox(
          width: 60,
          height: 60,
          child:
            Stack(
              children: [
                CircularProgressIndicator(
                  value: widget.appState.getProgress(),         
                  strokeWidth: 40,
                  color: Colors.blue,
                ),
                Text(
                  workingMessage, 
                  style: TextStyle(
                    fontSize: 16,
                  )
                ),
              ]
            ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}