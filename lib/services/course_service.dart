import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class CourseService {
  static final CourseService of = CourseService._();

  CourseService._();

  Future<ResBaseModel> getCourseGroup() async {
    final res = await HttpUtils.postNew(
      Api.courseGroupIndex,
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseGroupChoose(int id) async {
    final res = await HttpUtils.postNew(
      Api.courseGroupChoose,
      params: {
        "id": id //课程分组id
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseDefined() async {
    final res = await HttpUtils.postNew(
      Api.courseDefined,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseIndex(
    String? type, {
    required int pageNum,
    int pageSize = 20,
  }) async {
    final res = await HttpUtils.postNew(
      Api.courseIndex,
      params: {
        "filters": {
          "type": type,
        },
        "pageNum": pageNum,
        "pageSize": pageSize,
      },
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseTop() async {
    final res = await HttpUtils.postNew(
      Api.courseTop,
    );
    return res ?? ResBaseModel.defaultRes;
  }

}
