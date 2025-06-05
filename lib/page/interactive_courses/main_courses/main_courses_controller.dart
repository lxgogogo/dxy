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

  @override
  void onReady() {
    _loadData(isFirstLoad: true).whenComplete(() {
      hasLoaded.value = true;
    });
    super.onReady();
  }

  void onFocusGained() {
    if (hasLoaded.value) {
      _loadData(isFirstLoad: false);
    }
  }

  Future<void> _loadData({bool isFirstLoad = false}) async {
    await Future.wait([
      getCourseTop(),
      getCourseGroup(isFirstLoad: isFirstLoad),
    ]);
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
        item.state = 1;
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
        if (item.contentType == 'article') {
          Get.toNamed(Routes.articleDetail, arguments: item.contentId);
        } else if (item.contentType == 'video' || item.contentType == 'videoList') {
          Get.toNamed(Routes.videoDetail, arguments: {'id': item.contentId});
        }
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void toPractice(CourseModel item) {
    final id = item.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises);
  }

  void toChallenge(CourseModel item) {
    final id = item.id;
    if (id == null) return;
  }
}
