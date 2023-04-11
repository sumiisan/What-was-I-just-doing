import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:provider/provider.dart';
import 'package:what_was_i_just_doing/task_list.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//  widgets
import 'calendar.dart';
import 'idle.dart';
import 'working.dart';

//  state
import 'app_state.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 画面を縦向きに固定
    ]);
    var title = AppLocalizations.of(context)?.whatWasIJustDoing ?? "?";
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor:
           Color.fromARGB(255, 219, 146, 0),
           ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ja', 'JP'),
        ],
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)?.whatWasIJustDoing ?? "[a]";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color.fromARGB(255, 65, 65, 65),
          fontSize: 24,
        ),
        child: Center(
          child:
          ButtonTheme(
            minWidth: 400,
            height: 60,
            child: Localizations.override(   // override locale for testing purpose TODO: remove this later
              context: context,
              locale: const Locale('ja'),
              child: const ContentPage(),
            ),
          ), 
          
        ),
      ) 
    );
  }
}

class ContentPage extends StatelessWidget {
  const ContentPage({
    super.key,
  });

  Widget baseWidget(AppState appState) {
    return Column(
      children: [
        const CalendarWidget(),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset("assets/images/parrot.jpg"),
            ),
            Expanded(
              flex: 7,
              child: 
                  appState.activityState == ActivityState.idle 
                  ? IdleWidget(appState: appState) 
                  : WorkingWidget(appState: appState)
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    switch(appState.screenState) {
      case ScreenState.base:
        return baseWidget(appState);
      case ScreenState.taskList:
        return TaskListWidget(appState: appState);
    }
  }
}