part of 'select_courses_screen.dart';

class SelectCoursesController extends GetxController {
  RxList<SelectCoursesModel> courseTypes = <SelectCoursesModel>[].obs;

  RxInt selectedIndex = (-1).obs;

  @override
  void onReady() {
    getCourseGroup();
    super.onReady();
  }

  Future<void> getCourseGroup() async {
    try {
      final res = await CourseService.of.getCourseGroup();
      if (res.isSuccess) {
        final listRes = res.data as List;
        courseTypes.value = listRes.map((e) => SelectCoursesModel.fromJson(e)).toList();
      }
    } catch (e) {
      courseTypes.value = [];
    }
  }

  void selectOnTap(int index) {
    selectedIndex.value = index;
    courseTypes.refresh();
  }

  Future<void> onPressed() async {
    if (selectedIndex.value == -1) {
      DialogUtil.showToast('请选择一个最符合的描述');
      return;
    }
    final id = courseTypes[selectedIndex.value].id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseGroupChoose(id);
      if (res.isSuccess) {
        await StorageService.of.setSelectedCourseGroupId(id);
        await UserStore.of.updateUserInfo({'courseGroupId': id});
        Get.until((route) => route.settings.name == Routes.main);
        MainController.of.onTabBarItem(2);
      } else {
        // if (res.code == 405) {
        //   MainCoursesController.of.fetchData(needResetGroup: true);
        // }
        DialogUtil.showToast(res.msg);
      }
    } catch (e) {
      DialogUtil.showToast('选择失败!');
    }
  }
}
