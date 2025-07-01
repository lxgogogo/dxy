part of 'course_details_screen.dart';

class CourseDetailsController extends GetxController {
  late int? id;

  bool noNetwork = false;

  CourseModel? detailBean;

  bool isFetching = false;

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
    isFetching = true;
    try {
      final res = await CourseService.of.courseInfo(id, showLoading: false);
      if (res.isSuccess) {
        detailBean = CourseModel.fromJson(res.data);
        safeUpdate();
      }
    } finally {
      isFetching = false;
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

  Future<void> onStartCourse(BuildContext context) async {
    if (isFetching) return;
    final id = detailBean?.id;
    if (id == null) return;
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => CommonDialog(
        title: '开始学习',
        content: '是否开始学习该课程',
        onConfirm: () async {
          Navigator.of(context).pop();
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
        },
      ),
    );
  }

  Future<void> toKnowledge() async {
    if (isFetching) return;
    final id = detailBean!.knowledge!.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseRead(id);
      if (res.isSuccess) {
        final contentType = detailBean!.knowledge!.contentType;
        final contentId = detailBean!.knowledge!.contentId;
        final subContentId = detailBean!.knowledge!.subContentId;
        AppRoutesUtils.toDetail(contentType, contentId,
            subContentId: subContentId);
        requestDetail();
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice() {
    if (isFetching) return;
    final id = detailBean!.practise!.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': detailBean?.id});
  }

  void toChallenge() {
    if (isFetching) return;
    final id = detailBean!.challenge!.id;
    if (id == null) return;
  }

  void toChallengeItem(CourseModel item, ChallengeIndexDtoList model) {
    final id = model.id;
    if (id == null) return;
    CourseChallengeAlert.show(id, model.status,
        title: model.content ?? '', content: model.desc ?? '', callBack: () {
      model.status = 1;
      safeUpdate();
      requestDetail();
    });
  }
}
