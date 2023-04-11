import 'dart:async';
import 'dart:math';

//  entities
import 'calendar.dart';
import 'task.dart';

//  widgets
import 'idle.dart';
import 'working.dart';

//  services
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  utils
import 'simple_recorder.dart';
import 'audio_processing.dart';

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
  final _taskData = TaskData();
  final _audioProcessor = AudioProcessor();

  var activityState = ActivityState.idle;
  var remindFrequency = RemindFrequency.debug;
  var currentTask = Task();
  final _timer = WorkingTimer();
  int timerDuration = 0;
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

  AppState() {
    _audioProcessor.init();
  }

  // DI
  injectRecorder(Recorder instance) {  // TODO: improve DI mechanism
    recorder = instance;
  }

  @override
  dispose() {
    _timer.cancel();
    super.dispose();
  }

  // accessors
  Future<List<Task>> getTasks() async {
    await _taskData.loadTasks();
    return _taskData.tasks;
  }

  // Navigation

  startRecord() {
    recordButtonTapped();
  }

  recordButtonTapped() async { // start or stop record
    if (recorder == null) { return; }

    if (!recorder!.isInitialized()) {
      return;   // TODO: implement error handling
    }

    recorder?.mode = RecorderWidgetMode.record;

    if (recorder!.isRecording()) {
      await recorder!.stopRecorder();
      currentTask.mediaPath = recorder!.mediaPath;
      confirmTask();
    } else {
      await recorder?.record();
    }
  }

  confirmTask({Task? task}) {
    if (task != null) {
      currentTask = task;
    }

    recorder?.mode = RecorderWidgetMode.playback;
    notifyListeners();    

    _audioProcessor.playSequence(
      items: ["assets:audio/imakara","temp:${currentTask.mediaPath}","assets:audio/woShimasu"],
      onPlayEnded: () {
        recorder?.mode = RecorderWidgetMode.confirm;
        notifyListeners();
      }
    );
  }

  newTask() {
    currentTask = Task();
    recorder?.mode = RecorderWidgetMode.record;
    notifyListeners();
  }

  startWork({Task? task}) {
    if (task != null) {
      currentTask = task;
    }
    
    if (currentTask.timeSpent.inSeconds == 0) { // its a new task
      currentTask.created = DateTime.now();
      currentTask.mediaPath = recorder?.mediaPath ?? "";
    }

    activityState = ActivityState.working;
    notifyListeners();
    startReminder();
  }

  finishWork({bool isAborted = false}) {
    currentTask.isFinished = !isAborted;
    _taskData.storeTask(currentTask);
    currentTask = Task();   // because we have stored the task, we can clear the current task

    activityState = ActivityState.idle;
    stopReminder();
    notifyListeners();
  }

  startReminder() {
    scheduleNextReminder();
  }
  
  scheduleNextReminder() {
    // decide next reminder time
    var random = Random();
    var fluct = (maximumTimeTable[remindFrequency]! - minimumTimeTable[remindFrequency]!) * 60 * random.nextDouble(); // seconds
    timerDuration = (minimumTimeTable[remindFrequency]! * 60 + fluct).toInt(); // seconds

    _timer.start(Duration(seconds: timerDuration), onFinish: () {
      currentTask.timeSpent += Duration(seconds: timerDuration);
      doReminderTask();
    });
  }

  stopReminder() {
    _timer.cancel();
  }

  double getProgress() {
    return (_timer.elapsed.inMilliseconds / 1000) / timerDuration.toDouble();
  }

  doReminderTask() {
    /*
    if (recorder == null) { return; }
    recorder?.playRecorded().then((value) => {
      scheduleNextReminder()
    });
    */
    _audioProcessor.playSequence(
      items: [/*"assets:audio/imakara",*/"temp:${currentTask.mediaPath}"/*,"assets:audio/woShimasu"*/],
      onPlayEnded: () {
        scheduleNextReminder();
      }
    );

  }
}

class ContentPage extends StatelessWidget {
  const ContentPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

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
}