part of 'count_down_view.dart';

class CountDownController extends GetxController {
  var countdown = 60.obs;
  var isCountingDown = false.obs;

  void startCountdown(String type, String email) {
    NetRequest().sendCode(type, email, (data) {});
    isCountingDown.value = true;
    countdown.value = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
      } else {
        isCountingDown.value = false;
        timer.cancel();
      }
    });
  }
}
