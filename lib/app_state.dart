import 'dart:async';
import 'dart:math';

//  entities
import 'task.dart';

//  services
import 'package:flutter/material.dart';

//  utils
import 'simple_recorder.dart';
import 'audio_processing.dart';
import 'working_timer.dart';

enum ActivityState {
  idle,
  working,
}

enum ScreenState {
  base,
  taskList,
}

enum ModalDialogType {
  none,
  confirmRecord,
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
  var screenState = ScreenState.base;
  var modalDialogType = ModalDialogType.none;
  var remindFrequency = RemindFrequency.debug;
  var currentTask = Task();
  final _timer = WorkingTimer();
  int timerDuration = 0;
  Recorder? recorder;

  final minimumTimeTable = {  // minutes
    RemindFrequency.frequent: 2,
    RemindFrequency.normal: 5,
    RemindFrequency.rare: 10,
    RemindFrequency.debug: 0.5,
  };

  final maximumTimeTable = {  // minutes
    RemindFrequency.frequent: 5,
    RemindFrequency.normal: 10,
    RemindFrequency.rare: 30,
    RemindFrequency.debug: 1.0,
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
        openModalDialog(ModalDialogType.confirmRecord);
        notifyListeners();
      }
    );
  }

/*
  newTask() {
    currentTask = Task();
    recorder?.mode = RecorderWidgetMode.record;
    notifyListeners();
  }
*/

  startWork({Task? task}) {
    if (task != null) {
      currentTask = task;
    }
    
    if (currentTask.timeSpent.inSeconds == 0) { // its a new task
      currentTask.created = DateTime.now();
      currentTask.mediaPath = recorder?.mediaPath ?? "";
    }

    closeModalDialog();
    activityState = ActivityState.working;
    screenState = ScreenState.base;

    notifyListeners();
    startReminder();
  }

  finishWork({bool isAborted = false}) {
    stopReminder();

    currentTask.isFinished = !isAborted;
    _taskData.storeTask(currentTask);
    currentTask = Task();   // because we have stored the task, we can clear the current task

    activityState = ActivityState.idle;
    notifyListeners();
  }

  /*
   *
   *   Reminder
   *
   */

  startReminder() {
    scheduleNextReminder();
  }
  
  scheduleNextReminder() {
    // decide next reminder time
    var random = Random();
    var fluct = (maximumTimeTable[remindFrequency]! - minimumTimeTable[remindFrequency]!) * 60 * random.nextDouble(); // seconds
    timerDuration = (minimumTimeTable[remindFrequency]! * 60 + fluct).toInt(); // seconds

    currentTask.timeSpent += Duration(seconds: timerDuration);
    _timer.start(Duration(seconds: timerDuration), onFinish: () {
      doReminderTask();
    });
  }

  fireReminder() {
    _timer.cancel();
    doReminderTask();
  }

  stopReminder() {
    _timer.cancel();
  }

  double getProgress() {
    if (!_timer.isActive) return 0;
    return (_timer.elapsed.inMilliseconds / 1000) / timerDuration.toDouble();
  }

  doReminderTask() {
    var random = Random();
    var index = random.nextInt(3) + 1;
    _audioProcessor.playSequence(
      items: ["assets:audio/parrot$index", "temp:${currentTask.mediaPath}"],
      onPlayEnded: () {
        scheduleNextReminder();
      }
    );
  }

  /*
   *
   *   Task List
   *
   */
  openTaskList() {
    screenState = ScreenState.taskList;

    notifyListeners();
  }

  closeTaskList() {
    screenState = ScreenState.base;
    notifyListeners();
  }

  /*
   *
   *  Modal Dialog
   * 
   */

  openModalDialog(ModalDialogType type) {
    modalDialogType = type;
    notifyListeners();
  }

  closeModalDialog() {
    modalDialogType = ModalDialogType.none;
    notifyListeners();
  }

}
