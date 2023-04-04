import 'package:flutter/material.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What was I just doing?',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
      home: const MyHomePage(title: 'What was I just doing?'),
    );
  }
}

enum ActivityState {
  idle,
  working,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => AppState();
}

class AppState extends State<MyHomePage> {
  int counter = 0;
  var activityState = ActivityState.idle;
  final recorder = SimpleRecorder();

  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void startRecord() {
//    recorder.startRecording();
  }

  void recordingEnded() {
    setState(() {
      activityState = ActivityState.working;
    });

    Future.delayed(const Duration(seconds: 2), () {
//        recorder.playRecorded();
    });    
  }

  void finishWork() {
    setState(() {
      activityState = ActivityState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child:
        Localizations.override(   // override locale for testing purpose TODO: remove this later
            context: context,
            locale: const Locale('ja'),
            child: ContentPage(appState: this),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ContentPage extends StatelessWidget {
  const ContentPage({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    switch(appState.activityState) {
      case ActivityState.idle:
        return IdleWidget(appState: appState);
      case ActivityState.working:
        return WorkingWidget(appState: appState);
    }

  }
}