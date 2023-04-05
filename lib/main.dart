import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'idle.dart';
import 'working.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'simple_recorder.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)?.whatWasIJustDoing ?? "?";
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 40, 183, 194)),
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
        home: MyHomePage(),
      ),
    );
  }
}

enum ActivityState {
  idle,
  working,
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
          fontSize: 30,
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

class AppState extends ChangeNotifier {
  var activityState = ActivityState.idle;
  Recorder? recorder;

  // DI
  void injectRecorder(Recorder instance) {  // TODO: improve DI mechanism
    recorder = instance;
  }

  // Navigation

  void startRecord() {
    recordButtonTapped();
  }

  void recordButtonTapped() async {
    if (recorder == null) { return; }

    if (!recorder!.isInitialized()) {
      return;   // TODO: implement error handling
    }

    recorder?.mode = RecorderWidgetMode.record;

    if (recorder!.isRecording()) {
      await recorder?.stopRecorder();
      confirmRecord();
    } else {
      recorder?.record();
    }
  }

  void confirmRecord() {
    recorder?.mode = RecorderWidgetMode.playback;
    recorder?.onPlayEnded = () { recorder?.mode = RecorderWidgetMode.confirm; };
    recorder?.playSequence(["imakara","*","woShimasu"]);
  }

  void recordingEnded() {
    activityState = ActivityState.working;
    notifyListeners();
  }

  void finishWork() {
    activityState = ActivityState.idle;
    notifyListeners();
  }



}

class ContentPage extends StatelessWidget {
  const ContentPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    switch(appState.activityState) {
      case ActivityState.idle:
        return IdleWidget(appState: appState);
      case ActivityState.working:
        return WorkingWidget(appState: appState);
    }
  }
}