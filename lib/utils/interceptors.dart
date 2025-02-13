import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_util.dart';
import 'package:holdem/utils/debounce_util.dart';
import 'package:holdem/utils/devices_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/widget/dialog_tip.dart';

import 'env.dart';

/// 请求拦截器
class HttpHeaderInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = StorageService.of.getToken();
    if (token.isNotEmpty) {
      options.headers['X-Auth-Token'] = token;
    }
    options.headers = {
      ...options.headers,
      ...DevicesUtil.of.headerJson,
      ...AppUtil.of.headerJson,
    };
    super.onRequest(options, handler);
  }
}

/// 响应拦截器
class ResponseInterceptors extends InterceptorsWrapper {
  final _debounce = DebounceUtil(milliseconds: 300);

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // 兼容 null data
    var data = response.data ?? <String, dynamic>{};
    if (data is String) {
      data = jsonDecode(data);
    }
    if ((data is Map) && (response.statusCode == 200 || response.statusCode == 201)) {
      final dynamic code = data['code'];
      final String? msg = data['msg']?.toString();

      if (code == 401 &&
          ![
            Routes.login,
            // 其他不需要重复跳转登录页的路由
          ].contains(Get.currentRoute)) {
        // 只针对 401 用 debounce
        _debounce.run(() async {
          // if (UserStore.of.isLogin) {
          // showToast(msg ?? '请先登录', duration: const Duration(seconds: 2));
          if (Get.context != null) {
            final isConfirm = await showDialog(
              barrierDismissible: true,
              context: Get.context!,
              builder: (context) => const DialogTip(
                title: '账号已被登出',
                content: '您的账号已在其他设备上登录，若要继续，请重新登录',
              ),
            );
            if (isConfirm == true) {
              UserStore.of.clearUserStorage();
              Get.toNamed(Routes.login);
              return;
            }
          }
          // }
        });
      }
    }

    super.onResponse(response..data = data, handler);
  }
}

/// 日志拦截器
class LogsInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    Log.d("onRequest baseUrl: ${options.baseUrl}");
    Log.d("onRequest path: ${options.path}");
    Log.d('onRequest header: ${options.headers}');
    Log.d('onRequest params: ${options.queryParameters}');
    if (options.data != null) {
      Log.d('onRequest data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // if (response.data is Map) {
    final responseStr = response.toString();
    Log.d('onResponse ${response.requestOptions.path}: $responseStr');
    // }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.d('onError ${err.type}: $err');
    super.onError(err, handler);
  }
}

class ProxyInterceptor {
  static HttpClient interceptor() {
    final client = HttpClient();
    if (!Env.isProxy) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => Env.useBadCertificate;
      return client;
    }

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return Env.useBadCertificate;
    };

    client.findProxy = (uri) {
      if (!Env.isProxy) {
        return "DIRECT";
      }
      return "PROXY ${Env.httpProxyHost}:${Env.httpProxyPort}";
    };

    return client;
  }
}
