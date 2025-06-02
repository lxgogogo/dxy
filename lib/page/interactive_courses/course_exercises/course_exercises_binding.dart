import 'package:get/get.dart';

import 'course_exercises_controller.dart';

class CourseExercisesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CourseExercisesController());
  }
}
