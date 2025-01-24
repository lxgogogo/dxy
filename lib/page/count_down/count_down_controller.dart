part of 'count_down_view.dart';

class CountDownController extends GetxController {
  int countdown = 60;
  bool isCountingDown = false;

  void startCountdown(String type, String email) {
    NetRequest().sendCode(type, email, (data) {});
    isCountingDown = true;
    countdown = 60;
    safeUpdate();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
      } else {
        isCountingDown = false;
        timer.cancel();
      }
      safeUpdate();
    });
  }
}
