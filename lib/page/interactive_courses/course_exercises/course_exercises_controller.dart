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
  RxList<CourseExerciseAnswerModel> dataList =
      <CourseExerciseAnswerModel>[].obs;
  CourseExerciseAnswerModel? selectAnswerModel;
  RxBool submit = false.obs;
  RxInt currentPage = 0.obs;
  int totalPage = 0;
  int integral = 0;
  int completed = 0;
  // 连队次数
  int companiesNumber = 0;
  RxBool isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    _requestData();
  }

  void _requestData() async {
    int id = Get.arguments['id'] ?? 0;
    CourseService.of.coursePractise('$id').then((data) {
      totalPage = data.total ?? 0;
      integral = data.integral ?? 0;
      completed = data.completed ?? 0;
      practiseList.value = data.practiseList ?? [];
      if (practiseList.isNotEmpty) {
        dataList.value = practiseList[currentPage.value].options ?? [];
      }
    }).whenComplete(() {
      isLoading.value = false;
    });
  }

  void _result() {
    submit.value = false;
    for (final m in dataList) {
      m.select = false;
    }
    dataList.refresh();
    selectAnswerModel = null;
    if (currentPage.value < practiseList.length) {
      pageController.jumpToPage(currentPage.value);
    }
  }

  // TODO: Public Method
  void onPressed() async {
    if (currentPage.value >= practiseList.length) {
      ToastUtils.showToast('所有题目已练习完了！');
    }
    if (selectAnswerModel == null) {
      return;
    }
    final model = practiseList[currentPage.value];
    final data = await CourseService.of.courseAnswer(
        {'id': model.id, 'answer': selectAnswerModel?.title ?? ''});
    submit.value = true;
    selectAnswerModel?.isCorrect = data.answer ?? false;
    dataList.refresh();
    // 答题逻辑，不管对错，继续下一题
    currentPage.value += 1;
    if (data.answer == false) {
      // 答题错误记录
      companiesNumber = 0;
      errorDataList.add(model);
    } else {
      companiesNumber++;
    }
    // 结果弹窗
    String str = (data.answer ?? false) ? '泰裤辣！' : '不正确';
    AnswerResultsSheet.show(
        data.answer ?? false, data.answerStr ?? '', data.text ?? str,
        (isCorrect) {
      Get.close(0);
      _result();
    });
    // 效果弹窗
    if (companiesNumber == 5) {
      // 是否连对5题
      AnswerResultsPageSheet.show(2, () {
        Get.close(0);
        Get.close(0);
        _result();
      });
    } else {
      if (currentPage.value >= practiseList.length) {
        // 答题结束
        companiesNumber = 0;
        if (errorDataList.isEmpty) {
          // 已经完成过不在弹窗
          if (completed != totalPage) {
            // 全对
            completed = totalPage;
            AnswerResultsPageSheet.show(1, integral: integral, () {
              Get.close(0);
              Get.close(0);
              _result();
            });
          }
        } else {
          // 错题重刷
          AnswerResultsPageSheet.show(0, () {
            Get.close(0);
            Get.close(0);
            _result();
            currentPage.value = 0;
            completed = 0;
            totalPage = errorDataList.length;
            pageController.jumpToPage(0);
            practiseList.value = errorDataList;
            practiseList.refresh();
            errorDataList = [];
          });
        }
      }
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
