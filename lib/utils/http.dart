import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

// import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/storage.dart';
import 'package:get/get.dart' as Get;

import '../page/mine/page_login.dart';
import 'log_utils.dart';
import 'net_request.dart';

class Http {
  static final Http _instance = Http._internal();

  // 单例模式使用Http类，
  factory Http() => _instance;

  static late final Dio dio;
  final CancelToken _cancelToken = CancelToken();

  Http._internal() {
    dio = Dio();
  }

  ///初始化公共属性
  ///
  /// [baseUrl] 地址前缀
  /// [connectTimeout] 连接超时赶时间
  /// [receiveTimeout] 接收超时赶时间
  /// [interceptors] 基础拦截器
  void init({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, String>? headers,
    List<Interceptor>? interceptors,
    HttpClient Function()? proxyInterceptor,
  }) {
    dio.options = dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers ?? const {},
    );
    if (proxyInterceptor != null) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = proxyInterceptor;
    }
    // 在初始化http类的时候，可以传入拦截器
    if (interceptors != null && interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
  }

  // 关闭dio
  void cancelRequests({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
  }

  // 添加认证
  // 读取本地配置
  Map<String, dynamic>? getAuthorizationHeader() {
    String? token = StorageUtil().prefs != null ? StorageUtil().prefs!.getString('token') : '';
    // print('header token=======${token!}');
    Map<String, dynamic> headers = {
      'system': Platform.isAndroid ? "android" : "ios",
      'lang': 'zh_TW',
      "vcode": "1.0.0",
      "X-Auth-Token": token,
    };
    return headers;
  }

  Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool refresh = false,
    bool noCache = true,
    String? cacheKey,
    bool cacheDisk = false,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions = requestOptions.copyWith(
      extra: {
        "refresh": refresh,
        "noCache": noCache,
        "cacheKey": cacheKey,
        "cacheDisk": cacheDisk,
      },
    );
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    // try {
    Response response;
    response = await dio.get(
      path,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );

    return response.data;
    // } on DioError catch (e) {
    //   if (e.response)
    //   // return e.response!.data;
    // }
  }

  Future post(
    String path, {
    Map<String, dynamic>? params,
    // data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response;
    try {
      response = await dio.post(
        path,
        data: params,
        // data: data,
        // queryParameter5s: params,
        options: requestOptions,
        cancelToken: cancelToken ?? _cancelToken,
      );
    } catch (e) {
      print('请求发生错误：$e');
      return {};
    }

    if (response.data['code'] == 401) {
      print('未登录${response.data['code']}');
      // Global().mainPage.logout();
      // Global().hasLogin = false;
      // Global().token = '';
      // StorageUtil().clear();
      LoginHelper().clearGlobalUserInfo();

      // LoginPage();

      if (Get.Get.currentRoute != "/LoginPage") {
        Get.Get.to(LoginPage());
      }

      return <String, dynamic>{};
    }
    return response.data;
  }

  Future postFile(
    String path, {
    Map<String, dynamic>? params,
    // data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    FailureCallback? onFail,
  }) async {
    LogUtils.printAll("postFile params===>$params");
    String fileName = params?['file'].split('/').last; // 获取文件名
    var file = await MultipartFile.fromFile(params?['file'], filename: fileName);
    FormData formData = FormData.fromMap({
      'file': file,
      // 'fileType': params?['fileType'],
      // 'timestamp': params?['timestamp'],
      //  'apiKey': params?['apiKey'],
      // 'sign': params?['sign'],
    });

    Options requestOptions = options ?? Options();
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response;
    try {
      response = await dio.post(
        path,
        data: formData,
        // data: data,
        // queryParameter5s: params,
        options: requestOptions,
        cancelToken: cancelToken ?? _cancelToken,
        onSendProgress: (int sent, int total) {
          print(sent.toString() + '/' + total.toString());
          onSendProgress!(sent, total);
        },
      );
      print('net url:$path \n data:${response.data}');
    } catch (e) {
      print('postFile请求发生错误：$e');
      if (onFail != null) {
        onFail(e.toString());
      }
      return {};
    }
    return response.data;
  }

  Future postBytesFile(
    String path, {
    Map<String, dynamic>? params,
    file,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    FailureCallback? onFail,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    // _authorization!['Content-Type'] = 'application/octet-stream';
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    FormData formData = FormData.fromMap({
      // 'file': file,
      // ignore: prefer_interpolation_to_compose_strings
      'file': MultipartFile.fromBytes(file.bytes, filename: 'temp.' + file.extension)
      // 'fileType': params?['fileType'],
      // 'timestamp': params?['timestamp'],
      //  'apiKey': params?['apiKey'],
      // 'sign': params?['sign'],
    });
    var response;
    try {
      response = await dio.post(
        path,
        data: formData,
        // data: data,
        // queryParameter5s: params,
        options: requestOptions,
        cancelToken: cancelToken ?? _cancelToken,
        onSendProgress: (int sent, int total) {
          onSendProgress!(sent, total);
        },
      );
      print('net url:$path \n data:${response.data}');
    } catch (e) {
      print('postFile请求发生错误：$e');
      onFail!(e.toString());
      return {};
    }
    return response.data;
  }

  Future put(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.put(
      path,
      data: data,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response.data;
  }

  Future patch(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.patch(
      path,
      data: data,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response.data;
  }

  Future delete(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.delete(
      path,
      data: data,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response.data;
  }
}
