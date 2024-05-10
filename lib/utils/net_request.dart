import 'dart:async';

import 'package:holdem/utils/api.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/response.dart';
import 'package:holdem/view/forum/ToastUtils.dart';

import 'log_utils.dart';

typedef SuccessCallback = void Function(dynamic data);
typedef FailureCallback = void Function(String errorMsg);

class NetRequest {
  Future indexList(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.indexList, params: params);
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future getBoardList() async {
    var data = await HttpUtils.post(Api.boardList);
    print(data);
    return data;
  }

  ///论坛顶部板块列表
  Future getBoardData(SuccessCallback onSuccess) async {
    Map<String, Object> params = {};

    Map<String, dynamic> response =
        await HttpUtils.post(Api.boardList, params: params);
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///注册
  // register 注册
  static const String SEND_CODE_TYPE_REGISTER = "register";
  //resetPassword 重置密码
  static const String SEND_CODE_TYPE_RESET_PW = "resetPassword";
  Future sendCode(
      String type, String account, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['type'] = type;
    params['email'] = account;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.sendCode, params: params);
    LogUtils.printAll("sendCode===>$response");
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("sendCode success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///注册
  Future registerAccount(String account, String password, String code,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;
    params['code'] = code;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.register, params: params);
    LogUtils.printAll("registerAccount===>$response");
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("registerAccount success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///登录
  Future userLogin(
      String account, String password, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.login, params: params);
    LogUtils.printAll("userLogin===>$response");
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserProfile success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///退出登录
  Future logout(SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.logout);
    LogUtils.printAll("logout===>$response");
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("logout success===>");
      onSuccess(response);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///获取用户本人信息
  Future getUserInfo(String account, String password, SuccessCallback onSuccess,
      FailureCallback onFailure) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;

    Map<String, dynamic> response =
        await HttpUtils.get(Api.user, params: params);
    LogUtils.printAll("getUserInfo===>$response");
    Response resp = Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserInfo success===>");
      onSuccess(response['data']);
    } else {
      onFailure(resp.message!);
    }
  }
}
