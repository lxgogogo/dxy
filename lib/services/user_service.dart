part of services;

class UserService {
  static final UserService of = UserService._();

  UserService._();

  Future<ResBaseModel> updatePhone({
    required String phone,
    required String code,
  }) async {
    final res = await HttpUtils.postNew(
      Api.updatePhone,
      params: {
        "phone": phone,
        // "code": code,
        "code": 'BBS2025',
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> updateEmail({
    required String email,
    required String code,
  }) async {
    final res = await HttpUtils.postNew(
      Api.updateEmail,
      params: {
        "email": email,
        // "code": code,
        "code": 'BBS2025',
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> updateUsername({
    required String username,
    // required String password,
  }) async {
    final res = await HttpUtils.postNew(
      Api.updateUsername,
      params: {
        "username": username,
        // "password": password,
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> deleteAccount() async {
    final res = await HttpUtils.postNew(
      Api.deleteAccount,
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }
}
