part of services;

class LoginService {
  static final LoginService of = LoginService._();

  LoginService._();

  Future<ResBaseModel> login({
    required String accountType,
    required String account,
    required String password,
  }) async {
    final res = await HttpUtils.postNew(
      Api.login,
      params: {
        "accountType": accountType,
        "account": account,
        "password": password,
      },
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
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> thirdLogin({
    required String type,
    required String token,
  }) async {
    final res = await HttpUtils.postNew(
      Api.thirdLogin,
      params: {
        "thirdLoginType": type,
        "accessToken": token,
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }
}
