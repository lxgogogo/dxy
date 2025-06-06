import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/utils/toast_utils.dart';

import 'widget/AnswerResultsSheet.dart';
import 'widget/answer_results_page_sheet.dart';

class CourseExercisesController extends GetxController {

  final PageController pageController = PageController();
  RxList<CourseExerciseModel> practiseList = <CourseExerciseModel>[].obs;
  List<CourseExerciseModel> errorDataList = [];
  RxList<CourseExerciseAnswerModel> dataList = <CourseExerciseAnswerModel>[].obs;
  CourseExerciseAnswerModel? selectAnswerModel;
  RxBool submit = false.obs;
  RxInt currentPage = 0.obs;
  int totalPage = 0;
  int integral = 0;
  // 连队次数
  int companiesNumber = 0;
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
    dataList.value = practiseList[currentPage.value].options ?? [];
    isLoading.value = false;
  }

  void _result() {
    submit.value = false;
    Get.close(0);
    for (final m in dataList) {
      m.select = false;
    }
    dataList.refresh();
    selectAnswerModel = null;
    // 答题逻辑，不管对错，继续下一题
    currentPage+=1;
    if (currentPage < practiseList.length) {
      pageController.jumpToPage(currentPage.value);
    } else {
      companiesNumber = 0;
      currentPage.value = totalPage;
      // 答题结束了
      if (errorDataList.isEmpty) {
        // 全对
        AnswerResultsPageSheet.show(1, () {
          Get.close(0);
          Get.back();
        });
      } else {
        // 错题重刷
        AnswerResultsPageSheet.show(0, () {
          Get.close(0);
          currentPage.value = 0;
          pageController.jumpToPage(0);
          totalPage = errorDataList.length;
          practiseList.value = errorDataList;
          practiseList.refresh();
          errorDataList = [];
        });
      }
    }
  }

  void onPressed() async {
    if (selectAnswerModel == null) {
      ToastUtils.showToast('请选择答案!');
      return;
    }
    final model = practiseList[currentPage.value];
    final data = await CourseService.of.courseAnswer({
      'id': model.id,
      'answer': selectAnswerModel?.title ?? ''
    });
    submit.value = true;
    selectAnswerModel?.isCorrect = data.answer ?? false;
    dataList.refresh();
    if (data.answer == false) {
      // 答题错误记录
      companiesNumber = 0;
      errorDataList.add(model);
    } else {
      companiesNumber++;
    }
    // 是否连对5题
    if (companiesNumber == 5) {
      AnswerResultsPageSheet.show(2, () {
        _result();
      });
    } else {
      AnswerResultsSheet.show(data.answer ?? false, data.answerStr ?? '', (isCorrect) {
        _result();
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
