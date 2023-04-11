import 'dart:async' show Timer;
import 'dart:math';

enum RemindFrequency {
  debug,
  frequent,
  normal,
  rare,
}

typedef TimerCallback = void Function();

class RemindTimer {
  Duration interval = const Duration(seconds: 0);
  Duration elapsed = const Duration(seconds: 0);

  bool get isActive => timer?.isActive ?? false;
  DateTime _startDate = DateTime.now();
  Timer? timer;

  final _minimumIntervalTable = {  // minutes
    RemindFrequency.debug: 0.5,
    RemindFrequency.frequent: 2,
    RemindFrequency.normal: 5,
    RemindFrequency.rare: 10,
  };

  final _maximumIntervalTable = {  // minutes
    RemindFrequency.debug: 1.0,
    RemindFrequency.frequent: 5,
    RemindFrequency.normal: 10,
    RemindFrequency.rare: 30,
  };
  
  // decide next reminder interval
  int newInterval(RemindFrequency frequency) {
    var min = _minimumIntervalTable[frequency] ?? 5;
    var max = _maximumIntervalTable[frequency] ?? 10;

    var fluct = (max - min) * 60 * Random().nextDouble(); // seconds
    return (min * 60 + fluct).round(); // seconds
  }

  void start({required RemindFrequency frequency, TimerCallback? onFinish, TimerCallback? onTick}) {
    elapsed = const Duration(seconds: 0);
    _startDate = DateTime.now();
    interval = Duration(seconds: newInterval(frequency));
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      elapsed = DateTime.now().difference(_startDate);
      onTick?.call();
      if (elapsed > interval) {
        cancel();
        if (onFinish != null) onFinish();
      }
    });
  }

  void cancel() {
    timer?.cancel();
  }

}