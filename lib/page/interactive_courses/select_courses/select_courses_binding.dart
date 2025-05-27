import 'package:get/get.dart';

import 'select_courses_controller.dart';

class SelectCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectCoursesController());
  }
}
