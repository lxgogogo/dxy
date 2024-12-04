part of services;

class CommonService {
  static final CommonService of = CommonService._();

  CommonService._();

  Future saveReview() async {
    final res = await HttpUtils.post(Api.saveReview, showLoading: false);
    return res ?? ResBaseModel.defaultRes;
  }
}
