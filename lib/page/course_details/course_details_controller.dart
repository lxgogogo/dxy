part of 'course_details_screen.dart';

class CourseDetailsController extends GetxController {
  late int? id;

  bool noNetwork = false;

  CourseModel? detailBean;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments?['id'] as int?;
  }

  void onFocusGained() {
    requestDetail();
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestDetail();
  }

  requestDetail() async {
    if (id == null) return;
    try {
      final res = await CourseService.of.courseInfo(id, showLoading: false);
      if (res.isSuccess) {
        detailBean = CourseModel.fromJson(res.data);
        safeUpdate();
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      ToastUtils.showToast('请检查网络');
      return;
    }
    requestDetail();
  }

  Future<void> onStartCourse() async {
    final id = detailBean?.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseStart(id);
      if (res.isSuccess) {
        detailBean!.status = 1;
        safeUpdate();
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> toKnowledge() async {
    final id = detailBean!.knowledge!.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseRead(id);
      if (res.isSuccess) {
        final contentType = detailBean!.knowledge!.contentType;
        final contentId = detailBean!.knowledge!.contentId;
        AppRoutesUtils.toDetail(contentType, contentId);
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice() {
    final id = detailBean!.practise!.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': detailBean?.id});
  }

  void toChallenge() {
    final id = detailBean!.challenge!.id;
    if (id == null) return;
  }
}
