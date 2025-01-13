import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/storage.dart';

import '../stores/config_store.dart';
import 'env.dart';
import 'interceptors.dart';

class PreConfig {
  static bool _didInit = false;

  static Future<void> init() async {
    if (!_didInit) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      await Get.putAsync<StorageService>(
        () => StorageService().init(),
        permanent: true,
      );
      HttpUtils.init(
        baseUrl: Env.host,
        proxyInterceptor: ProxyInterceptor.interceptor,
        interceptors: [
          HttpHeaderInterceptors(),
          ResponseInterceptors(),
          LogsInterceptors(),
        ],
      );
      StorageUtil().init();
      Get.put<UserStore>(
        UserStore(),
        permanent: true,
      );
      Get.put<ConfigStore>(
        ConfigStore(),
        permanent: true,
      );
      _didInit = true;
    }
    return Future.value();
  }
}
