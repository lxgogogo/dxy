part of 'count_down_view.dart';

class CountDownController extends GetxController with WidgetsBindingObserver {
  Timer? _timer;
  RxInt countdown = 0.obs;
  static const int countdownDuration = 60;
  DateTime? _startTime;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 应用从后台返回，重新计算剩余时间
      _resumeCountdown();
    }
  }

  void startCountdown(String type, String email) async {
    if (_timer?.isActive == true) {
      return;
    }
    try {
      NetRequest().sendCode(type, email);
      _startTime = DateTime.now();
      countdown(countdownDuration);
      _startTimer();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send code: $e');
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
        final remainingSeconds = countdownDuration - elapsedSeconds;
        if (remainingSeconds <= 0) {
          resetCountdown();
        } else {
          countdown(remainingSeconds);
        }
      },
    );
  }

  void resetCountdown() {
    countdown(0);
    _timer?.cancel();
  }

  void _resumeCountdown() {
    if (_startTime != null) {
      final elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
      final remainingSeconds = countdownDuration - elapsedSeconds;
      if (remainingSeconds <= 0) {
        resetCountdown();
      } else {
        countdown(remainingSeconds);
        _startTimer();
      }
    }
  }
}
