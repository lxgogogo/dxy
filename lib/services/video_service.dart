part of services;

class VideoService {
  static final VideoService of = VideoService._();

  VideoService._();

  Future<ResBaseModel> recommendedVideos({
    int? id,
  }) async {
    final res = await HttpUtils.postNew(
      Api.recommendedVideos,
      params: {
        "id": id,
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }
}
