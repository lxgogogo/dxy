part of 'course_details_screen.dart';

class CourseDetailsController extends GetxController {
  late int? id;

  bool noNetwork = false;

  CourseModel? detailBean;

  bool isFetching = false;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments?['id'] as int?;
    requestDetail();
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestDetail();
  }

  requestDetail() async {
    if (id == null) return;
    isFetching = true;
    try {
      final res = await CourseService.of.courseInfo(id, showLoading: false);
      if (res.isSuccess) {
        // 先判断哪个选中(缓存起来)
        PractiseIndexDtoList? selectPractise;
        if (detailBean != null) {
          CourseModel practise = detailBean?.practise ?? CourseModel();
          final practiseIndexDtoList = practise.practiseIndexDtoList ?? [];
          for (int i = 0; i < practiseIndexDtoList.length; i++) {
            final model = practiseIndexDtoList[i];
            if (model.select == true) {
              selectPractise = model;
            }
          }
        }
        // 获取数据
        detailBean = CourseModel.fromJson(res.data);
        final knowledgeIndexDtoList = detailBean?.knowledge?.knowledgeIndexDtoList ?? [];
        if (knowledgeIndexDtoList.isNotEmpty) {
          final selectedIndex = knowledgeIndexDtoList.indexWhere((e) => e.isSelected);
          final startIndex = knowledgeIndexDtoList.indexWhere((e) => e.status == 0);
          if (selectedIndex != -1) {
            if (startIndex != -1) {
              if (startIndex > selectedIndex) {
                knowledgeIndexDtoList[startIndex].isSelected = true;
              } else {
                knowledgeIndexDtoList[selectedIndex].isSelected = true;
              }
            } else {
              knowledgeIndexDtoList[selectedIndex].isSelected = true;
            }
          } else {
            if (startIndex != -1) {
              knowledgeIndexDtoList[startIndex].isSelected = true;
            } else {
              knowledgeIndexDtoList.first.isSelected = true;
            }
          }
        }
        CourseModel practise = detailBean?.practise ?? CourseModel();
        final practiseIndexDtoList = practise.practiseIndexDtoList ?? [];
        for (int i = 0; i < practiseIndexDtoList.length; i++) {
          final model = practiseIndexDtoList[i];
          model.select = false;
          if (selectPractise != null) {
            if (model.id == selectPractise.id) {
              model.select = true;
            }
          } else {
            if (i == practiseIndexDtoList.length - 1) {
              model.select = true;
            }
          }
        }
        safeUpdate();
      }
    } finally {
      isFetching = false;
    }
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      DialogUtil.showToast('请检查网络');
      return;
    }
    requestDetail();
  }

  Future<void> onStartCourse(BuildContext context) async {
    if (isFetching) return;
    final id = detailBean?.id;
    if (id == null) return;
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => CommonDialog(
        title: '开始学习',
        content: '是否开始学习该课程',
        onConfirm: () async {
          Navigator.of(context).pop();
          try {
            final res = await CourseService.of.courseStart(id);
            if (res.isSuccess) {
              detailBean!.status = 1;
              safeUpdate();
            } else {
              DialogUtil.showToast(res.msg);
            }
          } catch (e) {
            Log.e(e.toString());
          }
        },
      ),
    );
  }

  Future<void> toKnowledge({Duration? duration}) async {
    if (isFetching) return;
    final knowledgeIndexDtoList = detailBean?.knowledge?.knowledgeIndexDtoList ?? [];
    final knowledgeIndexDto = knowledgeIndexDtoList.firstWhereOrNull((e) => e.isSelected);
    if (knowledgeIndexDto == null) {
      return;
    }
    int? contentId;
    int? subContentId;
    String? contentType;
    if (knowledgeIndexDto.contentVideo != null) {
      contentId = knowledgeIndexDto.contentId;
      subContentId = knowledgeIndexDto.subContentId;
      contentType = subContentId != null ? 'videoList' : 'video';
    } else if (knowledgeIndexDto.contentArticle != null) {
      contentId = knowledgeIndexDto.contentId;
      contentType = 'article';
    }
    if (knowledgeIndexDto.status == 1) {
      AppRoutesUtils.toDetail(
        contentType,
        contentId,
        subContentId: subContentId,
        duration: duration,
      );
    } else {
      try {
        final res = await CourseService.of.courseRead(knowledgeIndexDto.id);
        if (res.isSuccess) {
          AppRoutesUtils.toDetail(
            contentType,
            contentId,
            subContentId: subContentId,
            duration: duration,
            callBack: (value) {
              requestDetail();
            },
          );
        } else {
          DialogUtil.showToast(res.msg);
        }
      } catch (e) {
        Log.e(e.toString());
      }
    }
  }

  Future<void> onKnowledgeVideoComplete() async {
    try {
      final knowledgeIndexDtoList = detailBean?.knowledge?.knowledgeIndexDtoList ?? [];
      final knowledgeIndexDto = knowledgeIndexDtoList.firstWhereOrNull((e) => e.isSelected);
      if (knowledgeIndexDto != null) {
        if (knowledgeIndexDto.status == 1) {
          return;
        }
        final res = await CourseService.of.courseRead(knowledgeIndexDto.id);
        if (res.isSuccess) {
          await requestDetail();
        }
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  void onSelectKnowledgeItem(int index) {
    final knowledgeIndexDtoList = detailBean?.knowledge?.knowledgeIndexDtoList ?? [];
    for (int i = 0; i < knowledgeIndexDtoList.length; i++) {
      final model = knowledgeIndexDtoList[i];
      model.isSelected = false;
      if (i == index) {
        model.isSelected = true;
      }
    }
    safeUpdate();
  }

  void toPractice() {
    if (isFetching) return;
    final id = detailBean!.practise!.id;
    if (id == null) return;
    bool isFinish =
        (detailBean?.practise?.total ?? 0) > 0 && detailBean?.practise?.completed == detailBean?.practise?.total;
    final data = {'id': detailBean?.id, 'infoId': detailBean?.practise?.id};
    if (isFinish) {
      data['infoId'] = detailBean?.practise?.id ?? 0;
    }
    Get.toNamed(Routes.coursesExercises, arguments: data)?.then((value) {
      if (!isFinish) {
        requestDetail();
      }
    });
  }

  void toPracticeSelect(value) {
    CourseModel know = detailBean?.practise ?? CourseModel();
    final practiseIndexDtoList = know.practiseIndexDtoList ?? [];
    for (final model in practiseIndexDtoList) {
      model.select = false;
    }
    detailBean?.practise?.id = value.id ?? 0;
    detailBean?.practise?.infoTitle = value.title ?? '';
    detailBean?.practise?.contentType = value.contentType ?? '';
    detailBean?.practise?.contentId = value.contentId ?? 0;
    value.select = true;
    safeUpdate();
  }

  void toChallenge() {
    if (isFetching) return;
    final id = detailBean!.challenge!.id;
    if (id == null) return;
  }

  void toChallengeItem(CourseModel item, ChallengeIndexDtoList model) {
    final id = model.id;
    if (id == null) return;
    CourseChallengeAlert.show(id, model.status, title: model.content ?? '', content: model.desc ?? '', callBack: () {
      model.status = 1;
      item.completed = (item.completed ?? 0) + 1;
      safeUpdate();
      requestDetail();
    }, errorBack: () {
      Get.back();
    });
  }
}
