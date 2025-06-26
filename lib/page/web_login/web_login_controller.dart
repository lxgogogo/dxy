part of 'web_login_screen.dart';

class TelegramLoginController extends GetxController {
  bool isInit = false;

  InAppWebViewController? _webViewController;

  late String type;
  late String url;

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments?['type'] as String? ?? '';
    url = Get.arguments?['authUrl'] as String? ?? '';
  }

  @override
  void onReady() {
    clearCache().whenComplete(() {
      isInit = true;
      safeUpdate();
    });
    super.onReady();
  }

  void handleNativeBridge(List<dynamic> arguments) {
    Get.back(result: arguments.firstOrNull);
  }

  void handleOpenWebView(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      String targetUrl = arguments.first.toString();
      if (GetUtils.isURL(targetUrl)) {
        try {
          _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(targetUrl)));
          return;
        } catch (e) {
          ToastUtils.showToast('URL加载失败: $e');
        }
      } else {
        ToastUtils.showToast('无效的URL格式: $targetUrl');
      }
    } else {
      ToastUtils.showToast('无效的参数');
    }
  }

  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  Future<void> clearCache() async {
    // CookieManager cookieManager = CookieManager.instance();
    // await cookieManager.removeSessionCookies();
    // await cookieManager.deleteAllCookies();
    await InAppWebViewController.clearAllCache();
  }
}
