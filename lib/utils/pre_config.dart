import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:holdem/firebase_options.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/storage.dart';

import '../services/index.dart';
import '../stores/captcha_store.dart';
import '../stores/config_store.dart';
import 'env.dart';
import 'interceptors.dart';

class PreConfig {
  static bool _didInit = false;

  static Future<void> init() async {
    if (!_didInit) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
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
      GooglePlayServicesAvailability? availability;
      if (Platform.isAndroid) {
        availability = await GoogleApiAvailability.instance
            .checkGooglePlayServicesAvailability();
      }
      if (availability?.value != 5) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      Get.put<FirebaseService>(
        FirebaseService(),
        permanent: true,
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
      Get.put<CaptchaStore>(
        CaptchaStore(),
        permanent: true,
      );
      _didInit = true;
    }
    return Future.value();
  }
}
