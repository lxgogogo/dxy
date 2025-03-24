part of services;

class CommonService {
  static final CommonService of = CommonService._();

  CommonService._();

  Future<void> saveReview() async {
    await HttpUtils.postNew(Api.saveReview);
  }

  Future<void> sourceCreate(Uri linkUri) async {
    if (linkUri.isScheme('http') || linkUri.isScheme('https') || linkUri.isScheme('holdem')) {
      final interview = linkUri.toString().replaceAll('holdem://com.dxy.holdem', Env.shareHost);
      final source = linkUri.queryParameters['source'] ?? '';
      // if (source.isNotEmpty) {
      await HttpUtils.postNew(Api.sourceCreate, params: {
        "interview": interview,
        "source": source.isNotEmpty ? source : '直接访问',
        "deviceType": DevicesUtil.of.platformDesc,
      });
      // }
    }
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

  Future<ResBaseModel> searchTop({
    required int pageNum,
    int pageSize = 20,
    String keyword = '',
    bool isShowLoading = false,
  }) async {
    if (isShowLoading) {
      EasyLoading.show(status: 'loading...');
    }
    final res = await HttpUtils.postNew(Api.searchTop, params: {
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

  Future<ResBaseModel> reportDefined() async {
    EasyLoading.show(status: 'loading...');
    final res = await HttpUtils.postNew(Api.reportDefined).whenComplete(() {
      EasyLoading.dismiss();
    });
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> reportCreate(String relType, int id, int userId, {required String? reason}) async {
    EasyLoading.show(status: 'loading...');
    final res = await HttpUtils.postNew(Api.reportCreate, params: {
      'relType': relType,
      'relId': id,
      'relUserId': userId,
      'reason': reason,
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> getMessageBadge() async {
    final res = await HttpUtils.getNew(Api.messageBadge);
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> messageReadAll(String type) async {
    EasyLoading.show(status: 'loading...');
    final res = await HttpUtils.postNew(
      Api.messageReadAll,
      params: {
        'type': type,
      },
    ).whenComplete(() {
      EasyLoading.dismiss();
    });
    return res ?? ResBaseModel.defaultRes;
  }
}
