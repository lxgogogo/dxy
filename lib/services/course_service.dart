import 'package:get/get.dart';
import 'package:holdem/utils/dialog_util.dart';

import '../model/course_exercises_model.dart';
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

  Future<ResBaseModel> courseRead(int? id) async {
    final res = await HttpUtils.postNew(
      Api.courseRead,
      params: {
        "id": id, //课程id
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseStart(int? id) async {
    final res = await HttpUtils.postNew(
      Api.courseStart,
      params: {
        "id": id, //课程id
      },
      showLoading: true,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseInfo(int? id, {bool showLoading = true}) async {
    final res = await HttpUtils.postNew(
      Api.courseInfo,
      params: {
        "id": id, //课程id
      },
      showLoading: showLoading,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<CourseExerciseAllModel> coursePractise(params) async {
    final res = await HttpUtils.postNew(Api.coursePractise, params: params);
    CourseExerciseAllModel model = CourseExerciseAllModel.fromJson(res?.data);
    return model;
  }

  Future<CourseAnswerModel> courseAnswer(data) async {
    final res = await HttpUtils.postNew(Api.courseAnswer, params: data, showLoading: true);
    if (res?.isSuccess == true) {
      if (res?.data == null) {
        Get.back();
        DialogUtil.showToast('当前课程内容已被更改，请稍后再试');
        return CourseAnswerModel();
      } else {
        CourseAnswerModel model = CourseAnswerModel.fromJson(res?.data);
        return model;
      }
    } else {
      DialogUtil.showToast(res?.msg ?? '');
    }
    return CourseAnswerModel();
  }

  Future<ResBaseModel> coursePunch(String monthDate, {bool showLoading = true}) async {
    final res = await HttpUtils.postNew(
      Api.coursePunch,
      params: {
        "monthDate": monthDate,
      },
      showLoading: showLoading,
    );
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseRemind(params, {bool showLoading = true}) async {
    final res = await HttpUtils.postNew(Api.courseRemind, showLoading: showLoading, params: params);
    return res ?? ResBaseModel.defaultRes;
  }

  Future<ResBaseModel> courseChallenge(int id) async {
    final res = await HttpUtils.postNew(Api.courseChallenge, showLoading: true, params: {'id': id});
    return res ?? ResBaseModel.defaultRes;
  }
}
