part of 'course_details_screen.dart';

class CourseDetailsController extends GetxController {
  late int? id;
  bool loaded = false;

  bool noNetwork = false;

  CourseModel? detailBean;

  @override
  void onReady() {
    id = Get.arguments?['id'] as int?;
    dataInit();
    super.onReady();
  }

  void onFocusGained() {
    if (loaded) {
      requestDetail(showLoading: false);
    }
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestDetail(showLoading: false);
  }

  requestDetail({bool showLoading = true}) async {
    if (id == null) return;
    try {
      final res = await CourseService.of.courseInfo(id);
      if (res.isSuccess) {
        detailBean = CourseModel.fromJson(res.data);
      }
    } finally {
      loaded = true;
      safeUpdate();
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
        detailBean!.state = 1;
        safeUpdate();
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
        if (detailBean!.knowledge!.contentType == 'article') {
          Get.toNamed(
            Routes.articleDetail,
            arguments: detailBean!.knowledge!.contentId,
          );
        } else if (detailBean!.knowledge!.contentType == 'video' || detailBean!.knowledge!.contentType == 'videoList') {
          Get.toNamed(
            Routes.videoDetail,
            arguments: {'id': detailBean!.knowledge!.contentId},
          );
        }
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice() {
    final id = detailBean!.practise!.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises);
  }

  void toChallenge() {
    final id = detailBean!.challenge!.id;
    if (id == null) return;
  }
}
