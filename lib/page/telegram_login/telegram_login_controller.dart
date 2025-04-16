part of 'telegram_login_screen.dart';

class TelegramLoginController extends GetxController {
  handleJavaScriptCallback(List<dynamic> arguments) {
    Get.back(result: arguments.firstOrNull);
  }
}
