part of 'main_courses_screen.dart';

class MainCoursesController extends GetxController with RefreshControllerMixin {
  static MainCoursesController get of => Get.find<MainCoursesController>();

  Rx<CourseTopModel?> courseTopModel = Rx<CourseTopModel?>(null);

  double get courseProgress {
    if (courseTopModel.value == null) return 0;
    if (courseTopModel.value!.courseTotal == 0) return 0;
    return (courseTopModel.value?.courseCompleted ?? 0) / (courseTopModel.value!.courseTotal ?? 0);
  }

  List<CourseGroupModel> courseGroups = [];
  Rx<CourseGroupModel?> courseGroup = Rx<CourseGroupModel?>(null);

  final RxList<CourseModel> courseItems = <CourseModel>[].obs;

  RxBool hasLoaded = false.obs;

  StreamSubscription? refreshEvent;

  bool isFetching = false;

  @override
  void onReady() {
    refreshEvent = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      courseTopModel.value = null;
      courseGroups = [];
      courseGroup.value = null;
      courseItems.value = [];
      hasLoaded.value = false;
    });
    super.onReady();
  }

  void onFocusGained() {
    if (hasLoaded.value) {
      fetchData(needResetGroup: false);
    } else {
      fetchData(needResetGroup: true).whenComplete(() {
        hasLoaded.value = true;
      });
    }
  }

  Future<void> fetchData({bool needResetGroup = false}) async {
    isFetching = true;
    await Future.wait([
      getCourseTop(),
      getCourseGroup(needResetGroup: needResetGroup),
    ]).whenComplete(() async {
      isFetching = false;
      if (courseTopModel.value?.courseGroupId == null) {
        await UserStore.of.updateUserInfo({'courseGroupId': null});
        Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
          MainController.of.onTabBarItem(0);
          final homeScroller = HomeController.of.scrollController;
          if (homeScroller.hasClients) {
            homeScroller.jumpTo(0);
          }
        });
        return;
      }
      if ((courseTopModel.value!.integralPunch ?? 0) > 0) {
        // // 这里判断是否需要弹窗
        // final now = DateTime.now();
        // final lastPopupDateStr = await StorageService.of.getLastPopupDate();
        // if (lastPopupDateStr.isNotEmpty) {
        //   final lastPopupDate = DateTime.parse(lastPopupDateStr);
        //   if (now.day <= lastPopupDate.day) {
        //     return;
        //   }
        // }
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
          isDismissible: false,
        );
      }
    });
  }

  Future<void> getCourseGroup({bool needResetGroup = false}) async {
    try {
      final res = await CourseService.of.courseDefined();
      if (res.isSuccess) {
        final listRes = res.data?['courseGroup'] as List? ?? [];
        courseGroups = listRes.map((e) => CourseGroupModel.fromJson(e)).toList();
        if (courseGroups.isNotEmpty) {
          final id = await StorageService.of.getSelectedCourseGroupId();
          if (id != null) {
            courseGroup.value = courseGroups.firstWhereOrNull((e) => e.value?.des == id.toString());
            await StorageService.of.setSelectedCourseGroupId(null);

            courseGroup.value ??= courseGroups.first;
          } else {
            if (needResetGroup) {
              courseGroup.value = courseGroups.first;
            }
          }
          await onRefresh();
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
    if (page == 1) courseItems.clear();
    if (res.isSuccess) {
      final listRes = res.data?['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      courseItems.addAll(records);
      return records;
    }
    return null;
  }

  void onChangeType(CourseGroupModel type) {
    courseGroup.value = type;
    EasyLoading.show();
    hasLoaded.value = false;
    fetchData().whenComplete(() {
      EasyLoading.dismiss();
      hasLoaded.value = true;
    });
  }

  void toCourseDetail(CourseModel item) {
    Get.toNamed(Routes.courseDetails, arguments: {'id': item.id});
  }

  Future<void> onStartCourse(CourseModel item) async {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseStart(id);
      if (res.isSuccess) {
        item.status = 1;
        courseItems.refresh();
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> toKnowledge(CourseModel item) async {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseRead(id);
      if (res.isSuccess) {
        final contentType = item.contentType;
        final contentId = item.contentId;
        final subContentId = item.subContentId;
        AppRoutesUtils.toDetail(contentType, contentId, subContentId: subContentId);
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice(CourseModel item) {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': item.courseId ?? 0});
  }

  void toChallenge(CourseModel item) {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
  }

  void toWinningStreak() {
    Get.toNamed(Routes.winningStreak);
  }

  Future<void> onContinue() async {
    try {
      final res = await CourseService.of.courseRemind(showLoading: true);
      if (res.isSuccess) {
        Get.back();
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      ToastUtils.showToast(e.toString());
    }
    // Get.back();
    // final now = DateTime.now();
    // final nowFormatter = DateFormat('yyyy-MM-dd').format(now);
    // await StorageService.of.setLastPopupDate(nowFormatter);
  }
}
