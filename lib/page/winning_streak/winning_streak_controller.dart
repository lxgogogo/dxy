part of 'winning_streak_screen.dart';

class WinningStreakController extends GetxController {
  Rx<CoursePunchModel?> detailBean = Rx<CoursePunchModel?>(null);
  final Rx<DateTime> focusedDay = Rx<DateTime>(DateTime.now());

  bool hasLoaded = false;

  @override
  void onReady() {
    super.onReady();
    loadData(DateTime.now());
  }

  // TODO: Private Method

  void _fetchData() {
    if ((detailBean.value!.integralPunch ?? 0) > 0) {
      Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  margin: EdgeInsets.symmetric(vertical: 24.w),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: '#FF6200'.hexColor.withOpacity(0.1)),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    Assets.svg.iconCourseHot,
                    width: 36.w,
                    height: 36.w,
                  ),
                ),
                Text(
                  '我们已为你保住了连胜',
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    '已使用${detailBean.value?.integralPunch ?? 0}积分保住连胜，今天马上完成课程延续连胜吧！',
                    style: TextStyle(
                      color: '#666666'.hexColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                  child: CustomButton(
                    onPressed: _onContinue,
                    textColor: Colors.white,
                    height: 48.w,
                    radius: 8.w,
                    title: '继续',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierColor: Colors.black.withOpacity(0.4),
        isDismissible: false,
      );
    }
  }

  Future<void> _onContinue() async {
    try {
      final res = await CourseService.of.courseRemind({
        'remindType': 'punch'
      },showLoading: true);
      if (res.isSuccess) {
        Get.back();
      } else {
        DialogUtil.showToast(res.msg);
      }
    } catch (e) {
      DialogUtil.showToast(e.toString());
    }
  }

  // TODO: Public Method

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
        _fetchData();
      }
    } finally {
      hasLoaded = false;
    }
  }
}
