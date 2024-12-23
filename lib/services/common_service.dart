part of services;

class CommonService {
  static final CommonService of = CommonService._();

  CommonService._();

  Future<void> saveReview() async {
    await HttpUtils.postNew(Api.saveReview);
  }

  Future<ResBaseModel> tagIndex() async {
    final res = await HttpUtils.postNew(Api.tagIndex);
    return res ?? ResBaseModel.defaultRes;
  }
}
