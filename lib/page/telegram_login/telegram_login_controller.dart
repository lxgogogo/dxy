part of 'telegram_login_screen.dart';

class TelegramLoginController extends GetxController {
  bool isInit = false;

  // late WebViewController webViewController;

  @override
  void onReady() {
    // webViewController = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //         // onProgress: (int progress) {},
    //         // onPageStarted: (String url) {},
    //         // onPageFinished: (String url) {},
    //         // onHttpError: (HttpResponseError error) {},
    //         // // onWebResourceError: (WebResourceError error) {},
    //         // onNavigationRequest: (NavigationRequest request) {},
    //         ),
    //   )
    //   ..addJavaScriptChannel('NativeBridge', onMessageReceived: (message) {
    //     print('xxx $message');
    //   })
    //   ..loadRequest(
    //     Uri.parse(Env.telegramLogin),
    //   );
    clearCache().whenComplete(() {
      isInit = true;
      safeUpdate();
    });
    super.onReady();
  }

  handleJavaScriptCallback(List<dynamic> arguments) {
    Get.back(result: arguments.firstOrNull);
  }

  Future<void> clearCache() async {
    // CookieManager cookieManager = CookieManager.instance();
    // await cookieManager.removeSessionCookies();
    // await cookieManager.deleteAllCookies();
    await InAppWebViewController.clearAllCache();
  }
}
