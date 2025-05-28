import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/select_courses_model.dart';

class SelectCoursesController extends GetxController {

  RxList<SelectCoursesModel> dataList = <SelectCoursesModel>[
    SelectCoursesModel(
      name: '德州小白',
      icon: Assets.courses.iconSelectCourses1.path,
      content: '第一次接触德州扑克，从零开始',
      select: true
    ),
    SelectCoursesModel(
        name: '德州小白',
        icon: Assets.courses.iconSelectCourses2.path,
        content: '第一次接触德州扑克，从零开始'
    ),
    SelectCoursesModel(
        name: '德州小白',
        icon: Assets.courses.iconSelectCourses3.path,
        content: '第一次接触德州扑克，从零开始'
    ),
    SelectCoursesModel(
        name: '德州小白',
        icon: Assets.courses.iconSelectCourses4.path,
        content: '第一次接触德州扑克，从零开始'
    ),
    SelectCoursesModel(
        name: '德州小白',
        icon: Assets.courses.iconSelectCourses5.path,
        content: '第一次接触德州扑克，从零开始'
    ),
  ].obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void onPressed() {


  }

  void selectOnTap(e) {
    for (final model in dataList) {
      model.select = false;
    }
    e.select = true;
    dataList.refresh();
  }
}
