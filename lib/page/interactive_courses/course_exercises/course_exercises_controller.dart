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
    // Future.delayed(const Duration(milliseconds: 1500), () {
    //   AnswerResultsPageSheet.show(0, integral: integral, () {
    //     Get.close(0);
    //   });
    // });
  }

  void _requestData() async {
    int id = Get.arguments['id'] ?? 0;
    CourseService.of.coursePractise('$id').then((data) {
      integral = data.integral ?? 0;
      completed = data.completed ?? 0;
      practiseList.value = data.practiseList ?? [];
      totalPage = practiseList.length;
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
      dataList.value = practiseList[currentPage.value].options ?? [];
      for (final m in dataList) {
        m.select = false;
      }
      pageController.jumpToPage(currentPage.value);
    }
  }

  void _endAlert(data, {bool evenPairs = false}) {
    companiesNumber = 0;
    if (errorDataList.isEmpty) {
      // 全对
      completed = totalPage;
      AnswerResultsPageSheet.show(1, integral: integral, () {
        Get.close(0);
        // 判断是否最后答完有连对弹窗
        if (!evenPairs) {
          Get.close(0);
        }
        _result();
        Get.back();
      });
    } else {
      // 错题重刷
      AnswerResultsPageSheet.show(0, () {
        Get.close(0);
        // 判断是否最后答完有连对弹窗
        if (!evenPairs) {
          Get.close(0);
        }
        currentPage.value = 0;
        completed = 0;
        totalPage = errorDataList.length;
        pageController.jumpToPage(0);
        practiseList.value = errorDataList;
        dataList.value = errorDataList[0].options ?? [];
        practiseList.refresh();
        errorDataList = [];
        _result();
      });
    }
  }

  // 是否连对
  void _evenPairs(data, {bool end = false}) {
    if ((data.pairsText ?? '').isNotEmpty) {
      bool showPairsTips = data.integral > 0 ? true : false;
      AnswerResultsPageSheet.show(2,
          pairsText: data.pairsText ?? '',
          integral: data.integral ?? 0,
          showPairsTips: showPairsTips, () {
        Get.close(0);
        Get.close(0);
        _result();
        if (end) {
          _endAlert(data, evenPairs: true);
        }
      });
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
    if (data.id == null || data.status == null) {
      return;
    }
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
    if (currentPage.value >= practiseList.length) {
      // 答题结束
      if ((data.pairsText ?? '').isNotEmpty) {
        _evenPairs(data, end: true);
      } else {
        _endAlert(data);
      }
    } else {
      // 答题未结束
      _evenPairs(data);
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
