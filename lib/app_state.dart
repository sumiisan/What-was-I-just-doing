import 'dart:async';
import 'dart:math';

//  entities
import 'task.dart';

//  widgets
import 'idle.dart';
import 'working.dart';

//  services
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//  utils
import 'simple_recorder.dart';


enum ActivityState {
  idle,
  working,
}

enum RemindFrequency {
  frequent,
  normal,
  rare,
  debug,
}

class AppState extends ChangeNotifier {
  final taskData = TaskData();
  var activityState = ActivityState.idle;
  var remindFrequency = RemindFrequency.debug;
  var currentTask = Task();
  late Timer _timer;
  Recorder? recorder;

  final minimumTimeTable = {  // minutes
    RemindFrequency.frequent: 2,
    RemindFrequency.normal: 5,
    RemindFrequency.rare: 10,
    RemindFrequency.debug: 0.1,
  };

  final maximumTimeTable = {  // minutes
    RemindFrequency.frequent: 5,
    RemindFrequency.normal: 10,
    RemindFrequency.rare: 30,
    RemindFrequency.debug: 0.3,
  };

  // DI
  void injectRecorder(Recorder instance) {  // TODO: improve DI mechanism
    recorder = instance;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Navigation

  void startRecord() {
    recordButtonTapped();
  }

  void recordButtonTapped() async { // start or stop record
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

  void startWork() {
    if (currentTask.description.isEmpty) {
      currentTask.description = currentTask.id; // TODO: implement human friendly description
      currentTask.mediaPath = recorder?.mediaPath ?? "";
    }

    activityState = ActivityState.working;
    notifyListeners();
    startReminder();
  }

  void finishWork({bool isAborted = false}) {
    currentTask.isFinished = !isAborted;
    taskData.storeTask(currentTask);
    currentTask = Task();   // because we have stored the task, we can clear the current task

    activityState = ActivityState.idle;
    stopReminder();
    notifyListeners();
  }

  void startReminder() {
    scheduleNextReminder();
  }
  
  void scheduleNextReminder() {
    // decide next reminder time
    var random = Random();
    var fluct = (maximumTimeTable[remindFrequency]! - minimumTimeTable[remindFrequency]!) * 60 * random.nextDouble(); // seconds
    var duration = (minimumTimeTable[remindFrequency]! * 60 + fluct).toInt(); // seconds

    _timer = Timer(Duration(seconds: duration), () {
      doReminderTask();
    });
  }

  void stopReminder() {
    _timer.cancel();
  }

  void doReminderTask() {
    if (recorder == null) { return; }
    recorder?.playRecorded().then((value) => {
      scheduleNextReminder()
    });
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