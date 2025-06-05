import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/services/course_service.dart';

import 'widget/AnswerResultsSheet.dart';

class CourseExercisesController extends GetxController {

  final PageController pageController = PageController();
  RxList<CourseExerciseModel> practiseList = <CourseExerciseModel>[].obs;
  RxList<CourseExerciseAnswerModel> dataList = <CourseExerciseAnswerModel>[].obs;
  CourseExerciseAnswerModel? selectAnswerModel;
  RxBool submit = false.obs;
  int currentPage = 0;
  int totalPage = 0;
  int integral = 0;
  RxBool isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    requestData();
  }

  void requestData() async {
    final data = await CourseService.of.coursePractise('1');
    totalPage = data.total ?? 0;
    integral = data.integral ?? 0;
    practiseList.value = data.practiseList ?? [];
    dataList.value = practiseList[currentPage].options ?? [];
    isLoading.value = false;
  }

  void onPressed() async {
    final model = practiseList[currentPage];
    final data = await CourseService.of.courseAnswer({
      'id': model.id,
      'answer': selectAnswerModel?.title ?? ''
    });
    submit.value = true;
    selectAnswerModel?.isCorrect = data.answer ?? false;
    dataList.refresh();
    AnswerResultsSheet.show(data.answer ?? false, data.answerStr ?? '', (isCorrect) {
      submit.value = false;
      Get.close(0);
      for (final m in dataList) {
        m.select = false;
      }
      dataList.refresh();
      if (data.answer ?? false) {
        currentPage+=1;
        if (currentPage < practiseList.length) {
          pageController.jumpToPage(currentPage);
        } else {
          // 答题结束了
          print('答题结束了');
        }
      }
    });
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
