import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:holdem/utils/storage.dart';

import 'global.dart';
import 'log_utils.dart';

class Http {
  static final Http _instance = Http._internal();
  // 单例模式使用Http类，
  factory Http() => _instance;

  static late final Dio dio;
  final CancelToken _cancelToken = CancelToken();

  Http._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions();

    dio = Dio(options);

    // // 添加request拦截器
    // dio.interceptors.add(RequestInterceptor());
    // // 添加error拦截器
    dio.interceptors.add(ErrorInterceptor());
    // // // 添加cache拦截器
    // dio.interceptors.add(NetCacheInterceptor());
    // // // 添加retry拦截器
    // dio.interceptors.add(
    //   RetryOnConnectionChangeInterceptor(
    //     requestRetrier: DioConnectivityRequestRetrier(
    //       dio: dio,
    //       connectivity: Connectivity(),
    //     ),
    //   ),
    // );

    // 在调试模式下需要抓包调试，所以我们使用代理，并禁用HTTPS证书校验
    // if (PROXY_ENABLE) {
    //   (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (client) {
    //     client.findProxy = (uri) {
    //       return "PROXY $PROXY_IP:$PROXY_PORT";
    //     };
    //     //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
    //     client.badCertificateCallback =
    //         (X509Certificate cert, String host, int port) => true;
    //   };
    // }
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
  }) {
    dio.options = dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers ?? const {},
    );
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
    String? token = StorageUtil().prefs != null
        ? StorageUtil().prefs!.getString('token')
        : '';
    // print('header token=======${token!}');
    Map<String, dynamic> headers = {
      'system': kIsWeb
          ? "web"
          : Platform.isAndroid
              ? "android"
              : "ios",
      'lang': 'zh_TW',
      // 'deviceid': Global().deviceId,
      "vcode": "1.0.0",
      "X-Auth-Token": token,
    };
    // 从getx或者sputils中获取
    // String accessToken = Global.accessToken;
    String accessToken = ''; //Global().token;
    if (accessToken.isNotEmpty) {
      headers['center-token'] = accessToken;
    }
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
      print('未登录');
      // Global().mainPage.logout();
      // Global().hasLogin = false;
      // Global().token = '';
      // StorageUtil().clear();
    }
    return response.data;
  }

  Future postFile(
    String path, {
    Map<String, dynamic>? params,
    // data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    LogUtils.printAll("postFile params===>$params");
    String fileName = params?['file'].split('/').last; // 获取文件名
    var file =
        await MultipartFile.fromFile(params?['file'], filename: fileName);
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
    var response = await dio.post(
      path,
      data: formData,
      // data: data,
      // queryParameter5s: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );
    print('net url:$path \n data:${response.data}');
    return response.data;
  }

  Future postBytesFile(
    String path, {
    Map<String, dynamic>? params,
    file,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic>? _authorization = getAuthorizationHeader();
    _authorization!['Content-Type'] = 'application/octet-stream';
    if (_authorization != null) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    FormData formData = FormData.fromMap({
      // 'file': file,
      // ignore: prefer_interpolation_to_compose_strings
      'file':MultipartFile.fromBytes(file.bytes,filename: 'temp.'+file.extension)
      // 'fileType': params?['fileType'],
      // 'timestamp': params?['timestamp'],
      //  'apiKey': params?['apiKey'],
      // 'sign': params?['sign'],
    });
    var response = await dio.post(
      path,
      data: formData,
      // data: data,
      // queryParameter5s: params,
      options: requestOptions,
      cancelToken: cancelToken ?? _cancelToken,
    );
    print('net url:$path \n data:${response.data}');
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

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response!.statusCode == 401) {
      print('9527');
      // if (Global().showLogin) {
      //   return;
      // }
      // Global().mainPage.logout();
      // Global().showLogin = true;
      return;
    } else if (err.response!.statusCode == 500) {
      return;
    }
    // if (err.response!.statusCode == 500) {
    //   print('9527');
    //   return;
    // }
    if (err.response!.statusCode == 422) {
      return;
    }
    // if (err.response!.statusCode != 200) {
    //   // ignore: void_checks
    //   return err.response!.data;
    // }
    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    super.onResponse(response, handler);
  }
}
