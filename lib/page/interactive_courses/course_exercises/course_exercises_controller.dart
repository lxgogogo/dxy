import 'package:get/get.dart';
import 'package:holdem/model/course_exercises_model.dart';

import 'widget/AnswerResultsSheet.dart';

class CourseExercisesController extends GetxController {


  RxList<CourseExerciseAnswerModel> dataList = <CourseExerciseAnswerModel>[
    CourseExerciseAnswerModel(
      title: '玩家A获胜',
      isCorrect: false,
    ),
    CourseExerciseAnswerModel(
      title: '玩家B获胜',
      isCorrect: true,
    ),
    CourseExerciseAnswerModel(
      title: '荷官获胜',
      isCorrect: false,
    ),
    CourseExerciseAnswerModel(
      title: '两位玩家平分底池',
      isCorrect: false,
    ),
  ].obs;

  CourseExerciseAnswerModel? selectAnswerModel;
  RxBool submit = false.obs;

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
    if (selectAnswerModel != null) {
      submit.value = true;
      dataList.refresh();
      AnswerResultsSheet.show(selectAnswerModel?.isCorrect ?? false, (isCorrect) {
        submit.value = false;
        dataList.refresh();
        Get.close(0);
      });
    }
  }

  void selectOnTap(model) {
    selectAnswerModel = model;
    for (final m in dataList) {
      m.select = false;
    }
    model.select = true;
    dataList.refresh();
  }
}
