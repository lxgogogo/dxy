import 'package:flutter/services.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/storage.dart';

import 'env.dart';
import 'global.dart';
import 'interceptors.dart';

class PreConfig {
  static bool _didInit = false;

  static Future<void> init() async {
    if (!_didInit) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      HttpUtils.init(
        baseUrl: Env.host,
        proxyInterceptor: ProxyInterceptor.interceptor,
        interceptors: [
          HttpHeaderInterceptors(),
          LogsInterceptors(),
        ],
      );
      StorageUtil().init().then((_) {
        if (StorageUtil().prefs!.getString("token") != null) {
          Global().hasLogin = true;
          Global().token = StorageUtil().prefs!.getString("token")!;
        }
      });

      _didInit = true;
    }
    return Future.value();
  }
}
