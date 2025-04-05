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
        "code": code,
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }
}
