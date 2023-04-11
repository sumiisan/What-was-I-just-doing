import 'dart:async' show Timer;

typedef TimerCallback = void Function();

class WorkingTimer {
  Duration elapsed = const Duration(seconds: 0);
  bool get isActive => timer?.isActive ?? false;

  Duration _duration = const Duration(seconds: 0);
  DateTime _startDate = DateTime.now();
  Timer? timer;

  void start(Duration duration, {TimerCallback? onFinish, TimerCallback? onTick}) {
    elapsed = const Duration(seconds: 0);
    _startDate = DateTime.now();
    _duration = duration;
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      elapsed = DateTime.now().difference(_startDate);
      onTick?.call();
      if (elapsed > _duration) {
        cancel();
        if (onFinish != null) onFinish();
      }
    });
  }

  void cancel() {
    timer?.cancel();
  }

}