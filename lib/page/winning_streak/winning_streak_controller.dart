part of 'winning_streak_screen.dart';

class WinningStreakController extends GetxController {
  Rx<CoursePunchModel?> detailBean = Rx<CoursePunchModel?>(null);
  final Rx<DateTime> focusedDay = Rx<DateTime>(DateTime.now());

  bool isFetching = false;

  @override
  void onReady() {
    loadData(DateTime.now());
    super.onReady();
  }

  Future<void> loadData(DateTime date) async {
    // if (isFetching) {
    //   return;
    // }
    // isFetching = true;
    try {
      final formatData = DateFormat('yyyy-MM').format(date);
      final res = await CourseService.of.coursePunch(formatData, showLoading: true);
      if (res.isSuccess) {
        detailBean.value = CoursePunchModel.fromJson(res.data);
      }
    } finally {
      // isFetching = false;
    }
  }
}
