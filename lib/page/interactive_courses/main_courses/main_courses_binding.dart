part of 'main_courses_screen.dart';

class MainCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainCoursesController());
  }
}
