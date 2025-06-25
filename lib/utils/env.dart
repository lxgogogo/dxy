import 'package:flutter/foundation.dart';

enum ApiEnv {
  dev,
  test,
  prod1,
  prod2,
}

enum PlatformType {
  androidApk,
  androidAab,
  iosIpa,
  unknown,
}

ApiEnv _kApiEnv = ApiEnv.test;
PlatformType _kPlatformType = PlatformType.unknown;

// 从环境变量或构建配置中获取环境设置
void initEnv(String? env) {
  if (env != null) {
    switch (env.toLowerCase()) {
      case 'dev':
        _kApiEnv = ApiEnv.dev;
        break;
      case 'test':
        _kApiEnv = ApiEnv.test;
        break;
      case 'prod1':
        _kApiEnv = ApiEnv.prod1;
        break;
      case 'prod2':
        _kApiEnv = ApiEnv.prod2;
        break;
      default:
        _kApiEnv = ApiEnv.test;
    }
  }
}

// 从环境变量中获取平台类型设置
void initPlatformType(String? platformType) {
  if (platformType != null) {
    switch (platformType.toLowerCase()) {
      case 'android_apk':
        _kPlatformType = PlatformType.androidApk;
        break;
      case 'android_aab':
        _kPlatformType = PlatformType.androidAab;
        break;
      case 'ios_ipa':
        _kPlatformType = PlatformType.iosIpa;
        break;
      default:
        _kPlatformType = PlatformType.unknown;
    }
  }
}

ApiEnv get kAPiEnv => _kApiEnv;

PlatformType get kPlatformType => _kPlatformType;

class Env {
  static bool get isDistribute => kReleaseMode && _kApiEnv == ApiEnv.prod1 || _kApiEnv == ApiEnv.prod2;

  static bool isProxy = false;
  static String httpProxyHost = '192.168.0.101';
  static String httpProxyPort = '8888';

  static bool get useBadCertificate => kDebugMode;

  // 判断是否是Android aab平台
  static bool get isAndroidAAb => false;
  // static bool get isAndroidAAb => _kPlatformType == PlatformType.androidAab;

  // 判断是否是Android apk平台
  static bool get isAndroid => _kPlatformType == PlatformType.androidApk;

  // 判断是否是iOS平台
  static bool get isIOS => _kPlatformType == PlatformType.iosIpa;

  static String get host {
    switch (_kApiEnv) {
      case ApiEnv.dev:
        return 'https://school-java-dev.dx252.com';
      case ApiEnv.test:
        return 'https://school-java-fat.dx252.com';
      case ApiEnv.prod1:
        return 'https://school-java.dx261.com';
      case ApiEnv.prod2:
        return 'https://school-java.dx262.com';
    }
  }

  static String get shareHost {
    switch (_kApiEnv) {
      case ApiEnv.dev:
        return 'https://school-h5-web-dev.dx252.com';
      case ApiEnv.test:
        return 'https://school-h5-web-fat.dx252.com';
      case ApiEnv.prod1:
        return 'https://dpoker.club';
      case ApiEnv.prod2:
        return 'https://dpoker.club';
    }
  }

  static String telegramLogin = 'https://telegram-login-dev.dx252.com?type=app';
  static String googleLogin = 'https://google-login-dev.dx252.com?type=app';
  static String appleLogin = 'https://apple-login-dev.dx252.com?type=app';
}
