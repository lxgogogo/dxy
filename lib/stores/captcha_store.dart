import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gt4_flutter_plugin/gt4_flutter_plugin.dart';
import 'package:gt4_flutter_plugin/gt4_session_configuration.dart';

class CaptchaStore extends GetxController {
  static CaptchaStore get of => Get.find();

  Gt4FlutterPlugin? captcha;
  Completer<String>? completer;

  @override
  void onReady() {
    initCaptcha();
    super.onReady();
  }

  void initCaptcha() {
    final config = GT4SessionConfiguration()
      ..language = "zho"
      ..debugEnable = false;
    captcha = Gt4FlutterPlugin("a1180705fb3ea00bafb693d8cb40cafd", config);
    captcha!.addEventHandler(
      onShow: (Map<String, dynamic> message) async {
        // TO-DO
        // 验证视图已展示
        debugPrint("Captcha did show");
      },
      onResult: (Map<String, dynamic> message) async {
        debugPrint("Captcha result: " + message.toString());

        String status = message["status"];
        if (status == "1") {
          // TODO
          // 发送 message["result"] 中的数据向服务端二次查询接口查询结果
          // 对结果进行二次校验
          Map result = message["result"] as Map;
        } else {
          // 终端用户完成验证错误，验证会自动刷新
          debugPrint("Captcha 'onResult' state: $status");
        }
        completer?.complete('success');
      },
      onError: (Map<String, dynamic> message) async {
        debugPrint("Captcha onError: $message");
        String code = message["code"];
        // TODO 处理验证中返回的错误
        if (Platform.isAndroid) {
          // Android 平台
          if (code == "-14460") {
            // 验证会话已取消
          } else {
            // 更多错误码参考开发文档
            // https://docs.geetest.com/gt4/apirefer/errorcode/android
          }
        }

        if (Platform.isIOS) {
          // iOS 平台
          if (code == "-20201") {
            // 验证请求超时
          } else if (code == "-20200") {
            // 验证会话已取消
          } else {
            // 更多错误码参考开发文档
            // https://docs.geetest.com/gt4/apirefer/errorcode/ios
          }
        }

        completer?.complete('');
      },
    );
  }

  Future<String> verify() {
    completer = Completer<String>();
    captcha?.verify();
    return completer!.future;
  }
}
