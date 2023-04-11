import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() {}); });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ctx = AppLocalizations.of(context);

    var dateFormat = ctx?.dateTimeFormat ?? " MM-dd HH:mm:ss ";
    var locale = ctx?.localeName ?? "en_US";

    String dateString() {
      var formatter = DateFormat(dateFormat, locale);
      return formatter.format(DateTime.now());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.contain, 
          child: Text(
            dateString(), 
            textScaleFactor: 1.5,
          ),
        )
      ],
    );
  }
}