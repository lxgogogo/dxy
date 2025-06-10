part of 'winning_streak_screen.dart';

class WinningStreakController extends GetxController {
  Rx<CoursePunchModel?> detailBean = Rx<CoursePunchModel?>(null);
  final Rx<DateTime> _focusedDay = Rx<DateTime>(DateTime.now().subtract(Duration(days: 30)));
  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  Future<void> loadData() async {
    try {
      final res = await CourseService.of.coursePunch('2025-06', showLoading: true);
      if (res.isSuccess) {
        detailBean.value = CoursePunchModel.fromJson(res.data);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }
}
