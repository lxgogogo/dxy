import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:audioplayers/audioplayers.dart';

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
  RxInt completed = 0.obs;
  // 连队次数
  int companiesNumber = 0;
  RxBool isLoading = true.obs;
  RxBool isCorrect = false.obs;
  final audioPlayer = AudioPlayer();

  @override
  void onReady() {
    super.onReady();
    _requestData();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  void _requestData() async {
    int id = Get.arguments['id'] ?? 0;
    int infoId = Get.arguments['infoId'] ?? 0;
    print('infoId:$infoId');
    final data = {'id': '$id'};
    if (infoId > 0) {
      data['infoId'] = '$infoId';
    }
    CourseService.of.coursePractise(data).then((data) {
      integral = data.integral ?? 0;
      completed.value = data.completed ?? 0;
      totalPage = data.total ?? 0;
      practiseList.value = data.practiseList ?? [];
      print('practiseList: ${practiseList.length}');
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
    if (data.status == 2) {
      // 全对
      AnswerResultsPageSheet.show(1, integral: integral, () {
        Get.close(0);
        // 判断是否最后答完有连对弹窗
        if (!evenPairs) {
          Get.close(0);
        }
        _result();
        Get.back();
      });
    } else if (data.status == 3){
      // 错题重刷
      AnswerResultsPageSheet.show(0, () {
        Get.close(0);
        // 判断是否最后答完有连对弹窗
        if (!evenPairs) {
          Get.close(0);
        }
        currentPage.value = 0;
        submit.value = false;
        for (final m in dataList) {
          m.select = false;
        }
        dataList.refresh();
        selectAnswerModel = null;
        pageController.jumpToPage(0);
        _requestData();
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

  void _playSound(String name) async {
    await audioPlayer.release(); // 每次播放前释放
    await audioPlayer.play(AssetSource('sounds/$name.mp3'));
    await audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed
    );
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
    int infoId = Get.arguments['infoId'] ?? 0;
    final req = {'id': model.id, 'answer': selectAnswerModel?.title ?? ''};
    if (infoId > 0) {
      req['review'] = true;
    }
    final data = await CourseService.of.courseAnswer(req);
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
      _playSound('wrong');
    } else {
      companiesNumber++;
      _playSound('correct');
      // 进度条效果
      isCorrect.value = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        isCorrect.value = false;
      });
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
