import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'net_request.dart';

class Http {
  static final Http _instance = Http._internal();

  factory Http() => _instance;

  static late final Dio dio;

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
    if (interceptors != null && interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
  }

  Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      Response response;
      response = await dio.get(
        path,
        queryParameters: params,
        options: options,
      );

      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future post(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Response response;
    try {
      response = await dio.post(
        path,
        data: params,
        options: options,
      );
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future postFile(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    FailureCallback? onFail,
  }) async {
    String fileName = params?['file'].split('/').last; // 获取文件名
    var file = await MultipartFile.fromFile(params?['file'], filename: fileName);
    FormData formData = FormData.fromMap({
      'file': file,
    });

    Response response;
    try {
      response = await dio.post(
        path,
        data: formData,
        options: options,
        onSendProgress: (int sent, int total) {
          onSendProgress?.call(sent, total);
        },
      );
      return response.data;
    } catch (e) {
      onFail?.call(e.toString());
      return {};
    }
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
    FormData formData = FormData.fromMap(
      {
        'file': MultipartFile.fromBytes(
          file.bytes,
          filename: 'temp.${file.extension}',
        )
      },
    );
    Response response;
    try {
      response = await dio.post(
        path,
        data: formData,
        options: options,
        onSendProgress: (int sent, int total) {
          onSendProgress!(sent, total);
        },
      );
      return response.data;
    } catch (e) {
      onFail?.call(e.toString());
      return {};
    }
  }
}
