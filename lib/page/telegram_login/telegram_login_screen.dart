import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../utils/env.dart';

part 'telegram_login_controller.dart';

class TelegramLoginScreen extends StatelessWidget {
  const TelegramLoginScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TelegramLoginController>(
      init: TelegramLoginController(),
      builder: (controller) {
        return Scaffold(
            appBar: CommonAppBar.arrowBack(
              context,
              title: 'Telegram',
            ),
            body: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(Env.telegramLogin),
                  ),
                  initialSettings: InAppWebViewSettings(
                    supportZoom: false,
                    useHybridComposition: false,
                    clearCache: true,
                  ),
                  onLoadStart: (controller, url) {
                    EasyLoading.show(status: '加载中...');
                    controller.injectCSSCode(source: ':root {touch-action: pan-x pan-y;height: 100%}');
                  },
                  onLoadStop: (controller, url) async {
                    EasyLoading.dismiss();
                    controller.injectCSSCode(source: ':root {touch-action: pan-x pan-y;height: 100%}');
                  },
                  onProgressChanged: (_, progress) {
                    if (progress / 100 > 0.999) {
                      EasyLoading.dismiss();
                    }
                  },
                  onWebViewCreated: (webController) async {
                    webController.addJavaScriptHandler(
                      handlerName: 'NativeBridge',
                      callback: controller.handleJavaScriptCallback,
                    );
                  },
                ),
              ],
            ));
      },
    );
  }
}
