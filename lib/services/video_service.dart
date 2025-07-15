part of services;

class LoginService {
  static final LoginService of = LoginService._();

  LoginService._();

  Future<ResBaseModel> login({
    required String accountType,
    required String account,
    required String password,
    required CaptchaResultModel captchaResult,
  }) async {
    final res = await HttpUtils.postNew(
      Api.login,
      params: {
        "accountType": accountType,
        "account": account,
        "password": password,
        "validateDto": captchaResult.toPostJson(),
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> register({
    required String accountType,
    required String account,
    required String password,
    required String code,
  }) async {
    final res = await HttpUtils.postNew(
      Api.reg,
      params: {
        "accountType": accountType,
        "account": account,
        "password": password,
        if (code.isNotEmpty) "code": code,
        // "code": 'BBS2025',
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> resetPassword({
    required String verifyType,
    required String account,
    required String password,
    required String code,
  }) async {
    final res = await HttpUtils.postNew(
      Api.resetPassword,
      params: {
        "verifyType": verifyType,
        "account": account,
        "password": password,
        if (code.isNotEmpty) "code": code,
        // "code": 'BBS2025',
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> thirdLogin({
    required String type,
    required String token,
    bool? isOrigin,
  }) async {
    final res = await HttpUtils.postNew(
      Api.thirdLogin,
      params: {
        "thirdLoginType": type,
        "accessToken": token,
        if (isOrigin != null) "isOrigin": isOrigin,
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> bindThirdLogin({
    required String type,
    required String token,
    bool? isOrigin,
  }) async {
    final res = await HttpUtils.postNew(
      Api.bindThirdLogin,
      params: {
        "thirdLoginType": type,
        "accessToken": token,
        if (isOrigin != null) "isOrigin": isOrigin,
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> queryLoginCode({
    required String uuid,
  }) async {
    final res = await HttpUtils.postNew(
      Api.queryLoginCode,
      params: {
        "uuid": uuid,
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> confirmLoginCode({
    required String uuid,
  }) async {
    final res = await HttpUtils.postNew(
      Api.confirmLoginCode,
      params: {
        "uuid": uuid,
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }
}
