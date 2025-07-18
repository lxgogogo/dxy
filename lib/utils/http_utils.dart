import 'dart:io';

import 'package:dio/dio.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/model/res_base_model.dart';
import 'package:holdem/utils/http.dart';
import 'package:holdem/utils/log_util.dart';

import 'net_request.dart';

class HttpUtils {
  static void init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
    List<Interceptor>? interceptors,
    HttpClient Function()? proxyInterceptor,
  }) {
    Http().init(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      interceptors: interceptors,
      proxyInterceptor: proxyInterceptor,
    );
  }

  static Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().get(
      path,
      params: params ?? {},
      options: options,
    );
  }

  static Future post(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        DialogUtil.showLoading();
      }
      var ret = await Http().post(
        path,
        params: params ?? {},
        options: options,
      );
      return ret;
    } catch (e) {
      Log.d(e.toString());
    } finally {
      if (showLoading) {
        DialogUtil.dismiss();
      }
    }
    return {};
  }

  static Future postBytesFile(
    String path,
    file, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    FailureCallback? onFail,
  }) async {
    return await Http().postBytesFile(
      path,
      file: file,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onFail: onFail,
    );
  }

  static Future postFile(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    bool showLoading = true,
    FailureCallback? onFail,
  }) async {
    if (showLoading) {
      DialogUtil.showLoading();
    }
    var ret = await Http().postFile(
      path,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onFail: onFail,
    );
    if (showLoading) {
      DialogUtil.dismiss();
    }
    return ret;
  }

  /// GET 请求
  static Future<ResBaseModel?> getNew(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Response response;
    try {
      response = await Http.dio.get(url, queryParameters: params ?? {}, options: options);

      return ResBaseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST 请求
  static Future<ResBaseModel?> postNew(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    bool showLoading = false,
  }) async {
    Response response;
    try {
      if (showLoading) {
        DialogUtil.showLoading();
      }
      response = await Http.dio.post(url, data: params ?? {}, options: options);

      final res = response.data as Map<String, dynamic>?;
      if (res == null) return null;
      return ResBaseModel.fromJson(res);
    } on DioException catch (e) {
      return _handleError(e);
    } finally {
      if (showLoading) {
        DialogUtil.dismiss();
      }
    }
  }

  /// POST 请求
  static Future<ResBaseModel?> postNewDynamic(
    String url, {
    dynamic params,
    Options? options,
    bool showLoading = false,
  }) async {
    Response response;
    try {
      if (showLoading) {
        DialogUtil.showLoading();
      }
      response = await Http.dio.post(url, data: params ?? {}, options: options);

      final res = response.data as Map<String, dynamic>?;
      if (res == null) return null;
      return ResBaseModel.fromJson(res);
    } on DioException catch (e) {
      return _handleError(e);
    } finally {
      if (showLoading) {
        DialogUtil.dismiss();
      }
    }
  }

  static ResBaseModel? _handleError(DioException e) {
    String msg = 'Unknown error';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        msg = 'Connect timeout';
      case DioExceptionType.connectionError:
        msg = 'Connect error';
      case DioExceptionType.badCertificate:
        msg = 'Bad certificate';
      case DioExceptionType.sendTimeout:
        msg = 'Send timeout';
      case DioExceptionType.receiveTimeout:
        msg = 'Receive timeout';
      case DioExceptionType.badResponse:
        msg = 'Bad response';
      case DioExceptionType.cancel:
        msg = 'Request cancel';
      case DioExceptionType.unknown:
        msg = e.message ?? 'Unknown error';
    }
    return ResBaseModel(msg: msg, exception: e);
  }
}
