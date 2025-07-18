import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../utils/dialog_util.dart';

part 'web_login_controller.dart';

class WebLoginScreen extends StatelessWidget {
  const WebLoginScreen({
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
              title: controller.type,
            ),
            body: controller.isInit
                ? InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(controller.url)),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      userAgent: "Random",
                      supportZoom: false,
                      useHybridComposition: false,
                      cacheEnabled: false,
                      clearCache: true,
                      // 添加OAuth相关设置
                      thirdPartyCookiesEnabled: true,
                      allowsLinkPreview: false,
                      isFraudulentWebsiteWarningEnabled: false,
                    ),
                    onLoadStart: (controller, url) {
                      DialogUtil.showLoading();
                    },
                    onLoadStop: (controller, url) async {
                      DialogUtil.dismiss();
                    },
                    onProgressChanged: (_, progress) {
                      if (progress / 100 > 0.999) {
                        DialogUtil.dismiss();
                      }
                    },
                    onWebViewCreated: (webController) async {
                      controller.setWebViewController(webController);
                      webController.addJavaScriptHandler(
                        handlerName: 'NativeBridge',
                        callback: controller.handleNativeBridge,
                      );
                      webController.addJavaScriptHandler(
                        handlerName: 'OpenWebView',
                        callback: controller.handleOpenWebView,
                      );
                    },
                  )
                : const SizedBox());
      },
    );
  }
}
