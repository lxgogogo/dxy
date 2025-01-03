part of 'terms_privacy_screen.dart';

class TermsPrivacyController extends GetxController {
  String url = '';
  String title = '';
  bool isLoading = true;

  // void onAgree() {
  //   Get.back(result: true);
  // }

  void onLoadStop() {
    isLoading = false;
    update();
  }

  // void onWebTitleChanged(String newTitle) {
  //   if (newTitle.isEmpty || newTitle == title) return;
  //   title = newTitle;
  //   update();
  // }

  @override
  void onInit() {
    url = Get.arguments['url'] as String? ?? '';
    title = Get.arguments['title'] as String? ?? '';
    super.onInit();
  }
}
