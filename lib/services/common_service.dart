part of services;

class CommonService {
  static final CommonService of = CommonService._();

  CommonService._();

  Future<void> saveReview() async {
    await HttpUtils.postNew(Api.saveReview);
  }

  Future<ResBaseModel> tagIndex({
    required int pageNum,
    int pageSize = 20,
    String keyword = '',
  }) async {
    final res = await HttpUtils.postNew(Api.tagIndex, params: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    return res ?? ResBaseModel.defaultRes;
  }
}
