part of 'main_courses_screen.dart';

class MainCoursesController extends GetxController with RefreshControllerMixin {
  Rx<CourseType> courseType = Rx<CourseType>(CourseType.all);

  final RxList<SearchTop> items = <SearchTop>[].obs;

  @override
  void onReady() {
    onRefresh();
    super.onReady();
  }

  @override
  Future<List?> loadData() async {
    if (page == 1) items.clear();
    final res = await CommonService.of.searchTop(
      pageNum: page,
      pageSize: pageSize,
    );
    if (res.isSuccess) {
      final listRes = res.data as List;
      final records = listRes.map((e) => SearchTop.fromMap(e)).toList();
      items.addAll(records);
      return records;
    }
    return null;
  }

  void onChangeType(CourseType type) {
    courseType.value = type;
    onRefresh();
  }

  void toCourseDetail() {
    Get.toNamed(Routes.courseDetails);
  }
}
