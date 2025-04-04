part of services;

class LoginService {
  static final LoginService of = LoginService._();

  LoginService._();

  Future<ResBaseModel> login({
    required String account,
    required String password,
  }) async {
    final res = await HttpUtils.postNew(
      Api.login,
      params: {
        "account": account,
        "password": password,
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
