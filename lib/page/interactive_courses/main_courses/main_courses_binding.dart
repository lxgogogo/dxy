import 'package:get/get.dart';

import 'main_courses_controller.dart';

class MainCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainCoursesController());
  }
}
