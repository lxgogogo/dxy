part of 'splash_screen.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.wait([
      ThirdSDKConfig.init(),
      Future.delayed(const Duration(seconds: 1)),
    ]).whenComplete(() {
      Get.offAllNamed(Routes.main);
    });
  }
}
