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

    const themeColor = Color.fromARGB(255, 2, 139, 112);
    var colorScheme = ColorScheme.fromSeed(seedColor: themeColor);

    var themeData = ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.red,// colorScheme.primary,
        displayColor: Colors.red,//colorScheme.primary,
      ),
      /*
      textTheme: TextTheme(
        bodySmall: TextStyle(color: colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold), 
      ),*/
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.primary, width: 2),
        textStyle: TextStyle(color: colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      )),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.primary,
      ), 
    );
    
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: title,
        theme: themeData,
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
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color.fromARGB(255, 65, 65, 65),
          fontSize: 24,
        ),
        child: Center(
          child: Localizations.override(   // override locale for testing purpose TODO: remove this later
            context: context,
            locale: const Locale('ja'),
            child: const ContentPage(),
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
        const SizedBox(height: 50),
        const CalendarWidget(),
        const SizedBox(height: 50),
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