part of 'splash_screen.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.wait([
      ThirdSDKConfig.init(),
    ]).whenComplete(() {
      Get.offAllNamed(Routes.main);
    });
  }
}
