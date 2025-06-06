part of 'winning_streak_screen.dart';

class WinningStreakController extends GetxController {
  late int? id;

  CourseModel? detailBean;

  @override
  void onInit() {
    id = Get.arguments?['id'] as int?;
    super.onInit();
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  Future<void> loadData() async {
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

  Future<void> onStartCourse() async {
    final id = detailBean?.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseStart(id);
      if (res.isSuccess) {
        detailBean!.status = 1;
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
        final contentType = detailBean!.knowledge!.contentType;
        final contentId = detailBean!.knowledge!.contentId;
        AppRoutesUtils.toDetail(contentType, contentId);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice() {
    final id = detailBean!.practise!.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': detailBean?.practise?.courseId});
  }

  void toChallenge() {
    final id = detailBean!.challenge!.id;
    if (id == null) return;
  }
}
