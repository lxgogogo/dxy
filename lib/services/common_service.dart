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
    bool isShowLoading = false,
  }) async {
    if (isShowLoading) {
      EasyLoading.show(status: 'loading...');
    }
    final res = await HttpUtils.postNew(Api.tagIndex, params: {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'filters': {
        'q': keyword,
      }
    }).whenComplete(() {
      if (isShowLoading) {
        EasyLoading.dismiss();
      }
    });
    return res ?? ResBaseModel.defaultRes;
  }
}
