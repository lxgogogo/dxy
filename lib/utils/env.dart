import 'package:flutter/foundation.dart';

enum ApiEnv {
  dev,
  test,
  prod1,
  prod2,
}

ApiEnv _kApiEnv = ApiEnv.test;

ApiEnv get kAPiEnv => _kApiEnv;

class Env {
  static bool get isDistribute =>
      kReleaseMode && _kApiEnv == ApiEnv.prod1 || _kApiEnv == ApiEnv.prod2;

  static bool isProxy = false;
  static String httpProxyHost = '192.168.0.100';
  static String httpProxyPort = '8888';

  static bool get useBadCertificate => kDebugMode;

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
      default:
        return '';
    }
  }
  static String get shareHost {
    switch (_kApiEnv) {
      case ApiEnv.dev:
        return 'https://school-h5-web-dev.dx252.com';
      case ApiEnv.test:
        return 'https://school-h5-web-fat.dx252.com';
      case ApiEnv.prod1:
        return 'https://school-h5-web.dx261.com';
      case ApiEnv.prod2:
        return 'https://school-h5-web.dx262.com';
      default:
        return '';
    }
  }
}
