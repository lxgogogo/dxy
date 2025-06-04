part of 'select_courses_screen.dart';

class SelectCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectCoursesController());
  }
}
