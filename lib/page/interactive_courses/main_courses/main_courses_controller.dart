part of 'main_courses_screen.dart';

class MainCoursesController extends GetxController with RefreshControllerMixin {
  Rx<CourseTopModel?> courseTopModel = Rx<CourseTopModel?>(null);

  double get courseProgress {
    if (courseTopModel.value == null) return 0;
    if (courseTopModel.value!.courseTotal == 0) return 0;
    return (courseTopModel.value?.courseCompleted ?? 0) / (courseTopModel.value!.courseTotal ?? 0);
  }

  List<CourseGroupModel> courseGroups = [];
  Rx<CourseGroupModel?> courseGroup = Rx<CourseGroupModel?>(null);

  final RxList<CourseModel> items = <CourseModel>[].obs;

  RxBool hasLoaded = false.obs;

  void onFocusGained() {
    _loadData(isFirstLoad: !hasLoaded.value);
  }

  Future<void> _loadData({bool isFirstLoad = false}) async {
    await Future.wait([
      getCourseTop(),
      getCourseGroup(isFirstLoad: isFirstLoad),
    ]).whenComplete(() {
      hasLoaded.value = true;
    });
  }

  Future<void> getCourseGroup({bool isFirstLoad = false}) async {
    try {
      final res = await CourseService.of.courseDefined();
      if (res.isSuccess) {
        final listRes = res.data?['courseGroup'] as List? ?? [];
        courseGroups = listRes.map((e) => CourseGroupModel.fromJson(e)).toList();
        if (courseGroups.isNotEmpty) {
          if (isFirstLoad) {
            courseGroup.value = courseGroups.first;
          }
          onRefresh();
        }
      }
    } catch (e) {
      courseGroups = [];
      courseGroup.value = null;
    }
  }

  Future<void> getCourseTop() async {
    try {
      final res = await CourseService.of.courseTop();
      if (res.isSuccess) {
        courseTopModel.value = CourseTopModel.fromJson(res.data);
        if ((courseTopModel.value!.integralPunch ?? 0) == 0) {
          // 这里判断是否需要弹窗
          final now = DateTime.now();
          final lastPopupDateStr = await StorageService.of.getLastPopupDate();
          if (lastPopupDateStr.isNotEmpty) {
            final lastPopupDate = DateTime.parse(lastPopupDateStr);
            if (now.day <= lastPopupDate.day) {
              return;
            }
          }
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
                        '已使用${courseTopModel.value?.integralPunch ?? 0}积分保住连胜，今天马上完成课程延续连胜吧！',
                        style: TextStyle(
                          color: '#666666'.hexColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                      child: CustomButton(
                        onPressed: onContinue,
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
          );
        }
      }
    } catch (e) {
      courseTopModel.value = null;
    }
  }

  @override
  Future<List?> loadData() async {
    final type = courseGroup.value?.value?.des;
    final res = await CourseService.of.courseIndex(
      type,
      pageNum: page,
      pageSize: pageSize,
    );
    if (res.isSuccess) {
      final listRes = res.data?['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      if (page == 1) items.clear();
      items.addAll(records);
      return records;
    }
    return null;
  }

  void onChangeType(CourseGroupModel type) {
    courseGroup.value = type;
    EasyLoading.show();
    onRefresh().whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  void toCourseDetail(CourseModel item) {
    Get.toNamed(Routes.courseDetails, arguments: {'id': item.id});
  }

  Future<void> onStartCourse(CourseModel item) async {
    final id = item.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseStart(id);
      if (res.isSuccess) {
        item.status = 1;
        items.refresh();
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> toKnowledge(CourseModel item) async {
    final id = item.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseRead(id);
      if (res.isSuccess) {
        final contentType = item.contentType;
        final contentId = item.contentId;
        AppRoutesUtils.toDetail(contentType, contentId);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice(CourseModel item) {
    final id = item.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': item.courseId ?? 0});
  }

  void toChallenge(CourseModel item) {
    final id = item.id;
    if (id == null) return;
  }

  void toWinningStreak() {
    Get.toNamed(Routes.winningStreak);
  }

  Future<void> onContinue() async {
    final now = DateTime.now();
    final nowFormatter = DateFormat('yyyy-MM-dd').format(now);
    await StorageService.of.setLastPopupDate(nowFormatter);
  }
}
