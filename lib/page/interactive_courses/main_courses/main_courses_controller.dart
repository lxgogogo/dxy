part of 'main_courses_screen.dart';

class MainCoursesController extends GetxController with RefreshControllerMixin {
  static MainCoursesController get of => Get.find<MainCoursesController>();

  RxBool isLogin = UserStore.of.isLogin.obs;
  Rx<CourseTopModel?> courseTopModel = Rx<CourseTopModel?>(null);

  double get courseProgress {
    if (courseTopModel.value == null) return 0;
    if (courseTopModel.value!.courseTotal == 0) return 0;
    return (courseTopModel.value?.courseCompleted ?? 0) / (courseTopModel.value!.courseTotal ?? 0);
  }

  List<CourseGroupModel> courseGroups = [];
  Rx<CourseGroupModel?> courseGroup = Rx<CourseGroupModel?>(null);

  final RxList<CourseModel> courseItems = <CourseModel>[].obs;

  RxBool hasLoaded = false.obs;

  StreamSubscription? refreshEvent;
  StreamSubscription? outSubscription;
  StreamSubscription? homeSubscription;

  bool isFetching = false;

  RxBool showAlert = false.obs;

  ScrollController scrollController = ScrollController();

  @override
  void onReady() {
    refreshEvent = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      courseTopModel.value = null;
      courseGroups = [];
      courseGroup.value = null;
      courseItems.value = [];
      hasLoaded.value = false;
    });
    outSubscription = EventBusUtil.of.on<EventLogout>().listen((event) {
      courseTopModel.value = null;
      courseGroups = [];
      courseGroup.value = null;
      courseItems.value = [];
      hasLoaded.value = false;
      onFocusGained();
    });
    homeSubscription = EventBusUtil.of.on<EventHomeRefreshPractise>().listen((event) {
      if (courseGroup.value?.value?.des == 'practise') {
        hasLoaded.value = false;
        fetchData().whenComplete(() {
          hasLoaded.value = true;
        });
      }
    });
    super.onReady();
  }

  void onFocusGained() {
    isLogin.value = UserStore.of.isLogin;
    if (hasLoaded.value) {
      fetchData(needResetGroup: false);
    } else {
      fetchData(needResetGroup: true).whenComplete(() {
        hasLoaded.value = true;
      });
    }
  }

  Future<void> fetchData({bool needResetGroup = false}) async {
    isFetching = true;
    await Future.wait([
      getCourseTop(),
      getCourseGroup(needResetGroup: needResetGroup),
    ]).whenComplete(() async {
      isFetching = false;
      if (isLogin.value) {
        // 登录状态下展示
        if (courseTopModel.value?.courseGroupId == null) {
          await UserStore.of.updateUserInfo({'courseGroupId': null});
          Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
            MainController.of.onTabBarItem(0);
            final homeScroller = HomeController.of.scrollController;
            if (homeScroller.hasClients) {
              homeScroller.jumpTo(0);
            }
          });
          return;
        }
        if ((courseTopModel.value!.integralPunch ?? 0) > 0) {
          // // 这里判断是否需要弹窗
          // final now = DateTime.now();
          // final lastPopupDateStr = await StorageService.of.getLastPopupDate();
          // if (lastPopupDateStr.isNotEmpty) {
          //   final lastPopupDate = DateTime.parse(lastPopupDateStr);
          //   if (now.day <= lastPopupDate.day) {
          //     return;
          //   }
          // }
          Get.bottomSheet(
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                color: Colors.white,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      margin: EdgeInsets.symmetric(vertical: 24.w),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: '#FF6200'.hexColor.withOpacity(0.1)),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        Assets.svg.iconCourseHot,
                        width: 36.w,
                        height: 36.w,
                      ),
                    ),
                    Text(
                      '我们已为你保住了连胜',
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        '已使用${courseTopModel.value?.integralPunch ?? 0}积分保住连胜，今天马上完成课程延续连胜吧！',
                        style: TextStyle(
                          color: '#666666'.hexColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                      child: CustomButton(
                        onPressed: onContinue,
                        textColor: Colors.white,
                        height: 48.w,
                        radius: 8.w,
                        title: '继续',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierColor: Colors.black.withOpacity(0.4),
            isDismissible: false,
          );
        }
      }
    });
  }

  Future<void> getCourseGroup({bool needResetGroup = false}) async {
    try {
      final res = await CourseService.of.courseDefined();
      if (res.isSuccess) {
        final listRes = res.data?['courseGroup'] as List? ?? [];
        courseGroups = listRes.map((e) => CourseGroupModel.fromJson(e)).toList();
        if (courseGroups.isNotEmpty) {
          final id = await StorageService.of.getSelectedCourseGroupId();
          if (id != null) {
            courseGroup.value = courseGroups.firstWhereOrNull((e) => e.value?.des == id.toString());
            await StorageService.of.setSelectedCourseGroupId(null);
            courseGroup.value ??= courseGroups.first;
          } else {
            if (needResetGroup) {
              courseGroup.value = courseGroups.first;
            }
          }
          await onRefresh();
        }
      }
    } catch (e) {
      courseGroups = [];
      courseGroup.value = null;
    }
  }

  Future<void> getCourseTop() async {
    try {
      if (isLogin.value) {
        final res = await CourseService.of.courseTop();
        if (res.isSuccess) {
          courseTopModel.value = CourseTopModel.fromJson(res.data);
        }
      }
    } catch (e) {
      courseTopModel.value = null;
    }
  }

  @override
  Future<List?> loadData() async {
    final type = courseGroup.value?.value?.des;
    List<KnowledgeIndexDtoList> selectedKnowledgeIndexDtos = [];
    if (type == 'knowledge') {
      for (final item in courseItems) {
        final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
        if (knowledgeIndexDtoList.isNotEmpty) {
          for (final dto in knowledgeIndexDtoList) {
            if (dto.isSelected) {
              selectedKnowledgeIndexDtos.add(dto);
            }
          }
        }
      }
    }
    final res = await CourseService.of.courseIndex(
      type,
      pageNum: page,
      pageSize: pageSize,
    );
    if (page == 1) courseItems.clear();
    if (res.isSuccess) {
      final listRes = res.data?['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      for (final item in records) {
        final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
        if (knowledgeIndexDtoList.isNotEmpty) {
          final startIndex = knowledgeIndexDtoList.indexWhere((e) => e.status == 0);

          /// 希望你看得懂 😄
          bool hasAppliedSelected = false;
          if (selectedKnowledgeIndexDtos.isNotEmpty) {
            for (final selectedDto in selectedKnowledgeIndexDtos) {
              final matchIndex = knowledgeIndexDtoList.indexWhere((e) => e.id == selectedDto.id);
              if (matchIndex != -1) {
                final currentItem = knowledgeIndexDtoList[matchIndex];
                if (selectedDto.status == 1) {
                  knowledgeIndexDtoList[matchIndex].contentVideo = selectedDto.contentVideo;
                  knowledgeIndexDtoList[matchIndex].contentArticle = selectedDto.contentArticle;
                  knowledgeIndexDtoList[matchIndex].isSelected = true;
                  hasAppliedSelected = true;
                  break;
                } else if (selectedDto.status == 0) {
                  if (currentItem.status == 1) {
                    knowledgeIndexDtoList[matchIndex].contentVideo = selectedDto.contentVideo;
                    knowledgeIndexDtoList[matchIndex].contentArticle = selectedDto.contentArticle;
                    int? nextUnreadIndex;
                    for (int i = matchIndex + 1; i < knowledgeIndexDtoList.length; i++) {
                      if (knowledgeIndexDtoList[i].status == 0) {
                        nextUnreadIndex = i;
                        break;
                      }
                    }
                    if (nextUnreadIndex != null) {
                      knowledgeIndexDtoList[nextUnreadIndex].isSelected = true;
                    } else {
                      knowledgeIndexDtoList.last.isSelected = true;
                    }
                  } else {
                    knowledgeIndexDtoList[matchIndex].contentVideo = selectedDto.contentVideo;
                    knowledgeIndexDtoList[matchIndex].contentArticle = selectedDto.contentArticle;
                    knowledgeIndexDtoList[matchIndex].isSelected = true;
                  }
                  hasAppliedSelected = true;
                  break;
                }
              }
            }
          }
          if (!hasAppliedSelected) {
            if (startIndex != -1) {
              knowledgeIndexDtoList[startIndex].isSelected = true;
            } else {
              knowledgeIndexDtoList.last.isSelected = true;
            }
          }
        }
      }
      courseItems.addAll(records);
      return records;
    }
    return null;
  }

  void onChangeType(CourseGroupModel type) {
    bool canSelect = true;
    if (!UserStore.of.isLogin) {
      canSelect = type.value?.tourist != 1 && type.value?.des != 'ALL';
    }
    if (canSelect) {
      courseGroup.value = type;
      DialogUtil.showLoading();
      hasLoaded.value = false;
      fetchData().whenComplete(() {
        DialogUtil.dismiss();
        hasLoaded.value = true;
      });
    } else {
      DialogUtil.showToast('登录解锁全部内容');
    }
  }

  void toCourseDetail(CourseModel item) {
    Get.toNamed(Routes.courseDetails, arguments: {'id': item.id})?.whenComplete(() {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

  Future<void> onStartCourse(CourseModel item) async {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
    try {
      final res = await CourseService.of.courseStart(id);
      if (res.isSuccess) {
        item.status = 1;
        courseItems.refresh();
      } else {
        DialogUtil.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> toKnowledge(CourseModel item, {Duration? duration}) async {
    final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
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
              loadData();
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

  Future<void> onKnowledgeVideoComplete(int index) async {
    try {
      final knowledgeIndexDtoList = courseItems[index].knowledgeIndexDtoList ?? [];
      final knowledgeIndexDto = knowledgeIndexDtoList.firstWhereOrNull((e) => e.isSelected);
      if (knowledgeIndexDto != null) {
        if (knowledgeIndexDto.status == 1) {
          return;
        }
        knowledgeIndexDto.status = 1;
        final res = await CourseService.of.courseRead(knowledgeIndexDto.id);
        if (res.isSuccess) {
          await loadData();
        } else {
          DialogUtil.showToast(res.msg);
        }
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> onSelectKnowledgeItem(int index, int childIndex) async {
    final knowledgeIndexDtoList = courseItems[index].knowledgeIndexDtoList ?? [];
    final knowledgeIndexDto = knowledgeIndexDtoList[childIndex];
    if (knowledgeIndexDto.status == 1) {
      if (knowledgeIndexDto.contentVideo == null && knowledgeIndexDto.contentArticle == null) {
        final res = await CourseService.of.knowledgeInfo(
          knowledgeIndexDto.subContentId ?? knowledgeIndexDto.contentId ?? 0,
        );
        if (res.isSuccess) {
          if (res.data['contentVideo'] != null) {
            knowledgeIndexDtoList[childIndex].contentVideo = ContentVideo.fromJson(res.data['contentVideo']);
          } else if (res.data['contentArticle'] != null) {
            knowledgeIndexDtoList[childIndex].contentArticle = ContentArticle.fromJson(res.data['contentArticle']);
          }
        } else {
          DialogUtil.showToast(res.msg);
        }
      }
    }
    for (int i = 0; i < knowledgeIndexDtoList.length; i++) {
      final model = knowledgeIndexDtoList[i];
      model.isSelected = false;
      if (i == childIndex) {
        model.isSelected = true;
      }
    }
    courseItems.refresh();
  }

  void toPractice(CourseModel item) {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': item.courseId ?? 0});
  }

  void toChallenge(CourseModel item) {
    if (isFetching) return;
    final id = item.id;
    if (id == null) return;
  }

  void toChallengeItem(CourseModel item, ChallengeIndexDtoList model) {
    final id = model.id;
    if (id == null) return;
    CourseChallengeAlert.show(id, model.status, title: model.content ?? '', content: model.desc ?? '', callBack: () {
      model.status = 1;
      item.completed = (item.completed ?? 0) + 1;
      courseItems.refresh();
      page = 1;
      getCourseTop();
      loadData();
    }, errorBack: () {
      page = 1;
      courseItems.refresh();
      getCourseTop();
      loadData();
    });
  }

  void toWinningStreak() {
    Get.toNamed(Routes.winningStreak);
  }

  Future<void> onContinue() async {
    try {
      final res = await CourseService.of.courseRemind({'remindType': 'top'}, showLoading: true);
      if (res.isSuccess) {
        Get.back();
      } else {
        DialogUtil.showToast(res.msg);
      }
    } catch (e) {
      DialogUtil.showToast(e.toString());
    }
    // Get.back();
    // final now = DateTime.now();
    // final nowFormatter = DateFormat('yyyy-MM-dd').format(now);
    // await StorageService.of.setLastPopupDate(nowFormatter);
  }

  void endFunction(value) {
    if (value == true) {
      hasLoaded.value = false;
      fetchData().whenComplete(() {
        hasLoaded.value = true;
      });
    } else {
      getCourseTop();
      int practiseRemaining = courseTopModel.value?.practiseRemaining ?? 0;
      if (practiseRemaining - 1 < 0) {
        courseTopModel.value?.practiseRemaining = 0;
      } else {
        courseTopModel.value?.practiseRemaining = practiseRemaining - 1;
      }
      courseTopModel.refresh();
    }
  }
}
