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

  RxBool isLoaded = false.obs;

  @override
  void onReady() {
    initData();
    super.onReady();
  }

  void initData() {
    isLoaded.value = false;
    Future.wait([
      getCourseTop(),
      getCourseGroup(),
    ]).whenComplete(() {
      isLoaded.value = true;
    });
  }

  Future<void> getCourseGroup() async {
    try {
      final res = await CourseService.of.courseDefined();
      if (res.isSuccess) {
        final listRes = res.data?['courseGroup'] as List? ?? [];
        courseGroups = listRes.map((e) => CourseGroupModel.fromJson(e)).toList();
        if (courseGroups.isNotEmpty) {
          courseGroup.value = courseGroups.first;
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
    if (page == 1) items.clear();
    final type = courseGroup.value?.value?.des;
    final res = await CourseService.of.courseIndex(
      type,
      pageNum: page,
      pageSize: pageSize,
    );
    if (res.isSuccess) {
      final listRes = res.data?['ALL']['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      items.addAll(records);
      return records;
    }
    return null;
  }

  void onChangeType(CourseGroupModel type) {
    courseGroup.value = type;
    onRefresh();
  }

  void toCourseDetail() {
    Get.toNamed(Routes.courseDetails);
  }
}
