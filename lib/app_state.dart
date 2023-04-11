import 'dart:async' show Future;
import 'dart:math';

//  services
import 'package:flutter/material.dart';

//  entities
import 'task.dart';

//  utils
import 'simple_recorder.dart';
import 'audio_processing.dart';
import 'remind_timer.dart';

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

class AppState extends ChangeNotifier {
  final _taskData = TaskData();
  final _audioProcessor = AudioProcessor();

  var activityState = ActivityState.idle;
  var screenState = ScreenState.base;
  var modalDialogType = ModalDialogType.none;
  var remindFrequency = RemindFrequency.normal;
  var currentTask = Task();
  final _timer = RemindTimer();
  Recorder? recorder;

  AppState() {
    _audioProcessor.init();
    scheduleNextReminder();   // idle chirping
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

    scheduleNextReminder();   // idle chirping
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
    _timer.cancel();

    var remindFrequencyForCurrentActivity = remindFrequency;
    
    if (activityState == ActivityState.idle) {  // idle chirping
      remindFrequencyForCurrentActivity = RemindFrequency.normal;
      // TODO: silence idle chirping during night

    }
    
    _timer.start(frequency: remindFrequencyForCurrentActivity, onFinish: () {
      currentTask.timeSpent += _timer.interval;
      doReminderTask();
    });
    currentTask.timeSpent += const Duration(microseconds: 1);   // we add it right away to indicate that the task has started
  }

  fireReminder() {
    _timer.cancel();
    doReminderTask();
  }

  stopReminder() {
    _timer.cancel();
  }

  slowerNotificationFrequency() {
    changeNotificationFrequency(1);
  }

  fasterNotificationFrequency() {
    changeNotificationFrequency(-1);
  }

  changeNotificationFrequency(int direction) {
    var index = RemindFrequency.values.indexOf(remindFrequency);
    index += direction;
    if (index < 0) index = 0;
    if (index >= RemindFrequency.values.length) index = RemindFrequency.values.length - 1;
    remindFrequency = RemindFrequency.values[index];
    _timer.cancel();
    scheduleNextReminder();
  }

  double getProgress() {
    if (!_timer.isActive || _timer.interval.inMilliseconds == 0) return 0;
    return (_timer.elapsed.inMilliseconds / _timer.interval.inMilliseconds).clamp(0.0, 1.0);
  }

  doReminderTask() {
    var random = Random();
    var index = random.nextInt(3) + 1;

    var items = ["assets:audio/parrot$index"];
    if (activityState == ActivityState.working) {
      items.add("temp:${currentTask.mediaPath}");
    }

    _audioProcessor.playSequence(
      items: items,
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