import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:holdem/utils/http.dart';

class HttpUtils {
  static void init({
    required String baseUrl,
    // int connectTimeout = 15000,
    // int receiveTimeout = 15000,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    List<Interceptor>? interceptors,
  }) {
    Http().init(
      baseUrl: baseUrl,
      
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      interceptors: interceptors,
    );
  }



  static Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool refresh = false,
    bool noCache = true,
    String? cacheKey,
    bool cacheDisk = false,
  }) async {
    return await Http().get(
      path,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
      refresh: refresh,
      noCache: noCache,
      cacheKey: cacheKey,
    );
  }

  static Future post(
    String path, {
    // data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool showLoading = true,
  }) async {
    if(showLoading){
      EasyLoading.show(status: 'loading...');
    }
    var ret = await Http().post(
      path,
      // data: data,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
    );
    if(showLoading){
      EasyLoading.dismiss();
    }
    return ret;
  }

  static Future postFile(
    String path, {
    // data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
        bool showLoading = true,
  }) async {
    if(showLoading){
      EasyLoading.show(status: 'loading...');
    }
    var ret = await Http().postFile(
      path,
      // data: data,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
    );
    if(showLoading){
      EasyLoading.dismiss();
    }
    return ret;
  }

  static Future put(
    String path, {
    // data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await Http().put(
      path,
      // data: data,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future patch(
    String path, {
    // data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await Http().patch(
      path,
      // data: data,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future delete(
    String path, {
    // data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await Http().delete(
      path,
      // data: data,
      params: params ?? {},
      options: options,
      cancelToken: cancelToken,
    );
  }
}
