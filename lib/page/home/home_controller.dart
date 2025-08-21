part of 'home_screen.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  static HomeController get of => Get.find<HomeController>();

  final ScrollController scrollController = ScrollController();

  List<BannerBean> banners = [];
  List<ArticleBean> videoItems = [];

  List<CourseGroupModel> courseGroups = [];
  CourseGroupModel? courseGroup;
  bool showAlert = false;
  List<CourseModel> courseItems = [];

  List<IndexCategory> oldCourseItems = [];
  List<ArticleBean> bookItems = [];
  List<VideoBean> hotVideos = [];
  List<HomeHotTagModel> tagList = [];

  bool isShowHomeMenu = false;

  int bannerIndex = 0;

  int tagId = 0;

  bool isHotVideosLoading = false;
  late AnimationController animationController;
  bool isFirstLoad = false;

  // 菜单项动画控制器
  late List<AnimationController> menuAnimationControllers;

  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    menuAnimationControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..value = 1.0,
    );

    super.onInit();
  }

  void loadData({bool needResetGroup = true}) {
    Future.wait([
      loadBanners(),
      loadHotVideos(),
      if (needResetGroup) loadCourseGroup(),
      loadOldCourses(),
      loadBooks(),
      loadHotTags(),
      if (UserStore.of.isLogin) UserStore.of.getUserInfo(),
    ]).whenComplete(() {
      _startCourseAnimations();
    });
  }

  bool hasNetwork = false;

  @override
  Future<void> onReady() async {
    super.onReady();
    final result = await Connectivity().checkConnectivity();
    hasNetwork = !result.contains(ConnectivityResult.none);
    if (hasNetwork) {
      loadData();
    }
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (!hasNetwork) {
        final hasNetwork = !result.contains(ConnectivityResult.none);
        if (hasNetwork) loadData();
      }
    });
    scrollController.addListener(() {
      final isShow = scrollController.offset > (211.w + 16.w + 63.w + 16.w + 63.w);
      if (isShowHomeMenu != isShow) {
        isShowHomeMenu = isShow;
        safeUpdate();
      }
    });
    EventBusUtil.of.on<EventChangeMainTab>().listen((event) {
      if (event.tabIndex == 0) {
        loadData(needResetGroup: false);
      }
    });
    EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
    EventBusUtil.of.on<EventRefreshNum>().listen((event) {
      final videoIndex = videoItems.indexWhere((e) => e.id == event.id);
      if (videoIndex != -1) {
        videoItems[videoIndex].likeCount = event.likeCount;
        videoItems[videoIndex].favoriteCount = event.favoriteCount;
        videoItems[videoIndex].commentCount = event.commentCount;
        videoItems[videoIndex].viewCount = event.viewCount;
        safeUpdate();
      }
      final hotVideoIndex = hotVideos.indexWhere((e) => e.id == event.id);
      if (hotVideoIndex != -1) {
        hotVideos[hotVideoIndex].likeCount = event.likeCount;
        hotVideos[hotVideoIndex].commentCount = event.commentCount;
        hotVideos[hotVideoIndex].viewCount = event.viewCount;
        safeUpdate();
      }
    });
    EventBusUtil.of.on<EventLogout>().listen((event) {
      courseGroups = [];
      courseGroup = null;
      courseItems = [];
      loadData();
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
      safeUpdate();
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    for (final controller in menuAnimationControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> loadBanners() async {
    await NetRequest().indexBanner({
      'pos': 'index.banner',
      'type': '1',
      'version': '202503',
    }, showLoading: false, (data) {
      banners = List<BannerBean>.from(data.map((banner) => BannerBean.fromJson(banner)));
      safeUpdate();
    });
  }

  Future<void> loadVideos() async {
    await NetRequest().indexList(
      {
        'pageNum': 1,
        'pageSize': 4,
        'filters': {'categoryAlias': SourceType.video.categoryAlias, 'sort': 'popular', 'tagId': tagId}
      },
      showLoading: false,
      (data) {
        final items = List<ArticleBean>.from(
          data['list'].map((article) => ArticleBean.fromJson(article)),
        );
        if (items.isNotEmpty) {
          videoItems.assignAll(items);
          safeUpdate();
        }
      },
    );
  }

  Future<void> loadHotVideos() async {
    if (isHotVideosLoading) return;
    isHotVideosLoading = true;
    safeUpdate();
    animationController.repeat();
    final params = {
      "id": [0, 0, 0, 0],
      "size": 4
    };
    if (hotVideos.isNotEmpty) {
      params['id'] = hotVideos.map((e) => e.id).toList();
      params['size'] = hotVideos.length;
    }
    await Future.wait([
      NetRequest().hotVideo(
        params,
        showLoading: false,
        (data) {
          final items = List<VideoBean>.from(
            data.map((article) => VideoBean.fromMap(article)),
          );
          if (items.isNotEmpty) {
            hotVideos.assignAll(items);
          }
        },
      ),
      Future.delayed(const Duration(milliseconds: 500)),
    ]).whenComplete(() {
      isHotVideosLoading = false;
      safeUpdate();
      animationController.stop();
    });
  }

  Future<void> loadHotTags() async {
    tagList = await HomeService.queryTopHeatTag({'pageNum': 1, 'pageSize': 100});
    tagId = tagList[0].id ?? 0;
    loadVideos();
    safeUpdate();
  }

  void toVideoList() {
    Get.toNamed(Routes.videoList);
  }

  Future<void> onChangeType(CourseGroupModel type) async {
    bool canSelect = true;
    if (!UserStore.of.isLogin) {
      canSelect = type.value?.tourist != 1 && type.value?.des != 'ALL';
    }
    if (canSelect) {
      courseGroup = type;
      await loadCourses();
    } else {
      DialogUtil.showToast('登录解锁全部内容');
    }
  }

  Future<void> loadCourseGroup() async {
    try {
      final res = await CourseService.of.courseDefined();
      if (res.isSuccess) {
        final listRes = res.data?['courseGroup'] as List? ?? [];
        courseGroups = listRes.map((e) => CourseGroupModel.fromJson(e)).toList();
        if (courseGroups.isNotEmpty) {
          courseGroup = courseGroups.first;
          safeUpdate();
          await loadCourses();
        }
      }
    } catch (e) {
      courseGroups = [];
      courseGroup = null;
    }
  }

  Future<void> loadCourses() async {
    final type = courseGroup?.value?.des;
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
      pageNum: 1,
      pageSize: 3,
    );
    if (res.isSuccess) {
      final listRes = res.data?['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      final des = courseGroup?.value?.des;
      if (des == 'knowledge') {
        /// 希望你看得懂 😄
        for (final item in records) {
          final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
          if (knowledgeIndexDtoList.isNotEmpty) {
            final startIndex = knowledgeIndexDtoList.indexWhere((e) => e.status == 0);
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
      }
      courseItems.assignAll(records.take(2));
      safeUpdate();
      isFirstLoad = true;
    }
  }

  void toCourseDetail(CourseModel item) {
    Get.toNamed(Routes.courseDetails, arguments: {'id': item.id});
  }

  Future<void> loadOldCourses() async {
    await NetRequest().courseCategory(
      {
        "parentAlias": "course",
        "parentId": 1,
      },
      showLoading: false,
      (data) {
        final items = List<IndexCategory>.from(
          data.map((category) => IndexCategory.fromJson(category)),
        );
        if (items.isNotEmpty) {
          oldCourseItems.assignAll(items);
          safeUpdate();
        }
      },
    );
  }

  Future<void> loadBooks() async {
    await NetRequest().bookRecommend({"pageSize": 4}, showLoading: false, (data) {
      final items = List<ArticleBean>.from(
        data.map((article) => ArticleBean.fromJson(article)),
      );
      if (items.isNotEmpty) {
        bookItems.assignAll(items);
        safeUpdate();
      }
    });
  }

  void jumpPage() {
    final bean = banners[bannerIndex];
    if (bean.jumpValue == null) return;
    if (bean.jumpType == 'url') {
      if (bean.jumpValue?.isNotEmpty == true) {
        launchUrlString(bean.jumpValue!, mode: LaunchMode.externalApplication);
      }
      return;
    }
    var id = int.tryParse(bean.jumpValue!);
    if (id == null) return;
    if (bean.jumpType == 'book') {
      Get.toNamed(Routes.bookDetail, arguments: id);
    } else if (bean.jumpType == 'article') {
      Get.toNamed(Routes.articleDetail, arguments: id);
    } else if (bean.jumpType == 'video' || bean.jumpType == 'videoList') {
      Get.toNamed(Routes.videoDetail, arguments: {'id': id});
    } else if (bean.jumpType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
    } else if (bean.jumpType == 'tool') {
      Get.toNamed(Routes.toolDetail, arguments: id);
    }
  }

  void onIndexChanged(int value) {
    bannerIndex = value;
  }

  changeMainTab(int i) {
    Get.find<MainController>().onTabBarItem(i);
  }

  void tagOnTap(value) async {
    DialogUtil.showLoading();
    tagId = value.id ?? 0;
    await loadVideos();
    DialogUtil.dismiss();
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
              loadCourses();
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

  Future<void> onKnowledgeVideoComplete(int childIndex) async {
    try {
      final knowledgeIndexDtoList = courseItems[childIndex].knowledgeIndexDtoList ?? [];
      final knowledgeIndexDto = knowledgeIndexDtoList.firstWhereOrNull((e) => e.isSelected);
      if (knowledgeIndexDto != null) {
        if (knowledgeIndexDto.status == 1) {
          return;
        }
        final res = await CourseService.of.courseRead(knowledgeIndexDto.id);
        if (res.isSuccess) {
          await loadCourses();
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
    safeUpdate();
  }

  void toPractice(CourseModel item) {
    final id = item.id;
    if (id == null) return;
    Get.toNamed(Routes.coursesExercises, arguments: {'id': item.courseId ?? 0});
  }

  void toChallenge(CourseModel item) {
    final id = item.id;
    if (id == null) return;
  }

  void toChallengeItem(CourseModel item, ChallengeIndexDtoList model) {
    final id = model.id;
    if (id == null) return;
    CourseChallengeAlert.show(id, model.status, title: model.content ?? '', content: model.desc ?? '', callBack: () {
      model.status = 1;
      item.completed = (item.completed ?? 0) + 1;
      safeUpdate();
      loadCourses();
    }, errorBack: () {
      loadCourses();
      safeUpdate();
    });
  }

  void endFunction(value) {
    if (value == true) {
      loadCourses();
    }
    EventBusUtil.of.fire(EventHomeRefreshPractise());
  }

  void onFocusGained() {
    if (isFirstLoad) {
      loadCourses();
    }
  }

  /// 启动菜单项动画序列
  void _startCourseAnimations() {
    _animateMenuItems();
  }

  /// 依次启动每个菜单项的动画
  void _animateMenuItems() {
    _animateMenuItemAtIndex(0);
  }

  /// 递归播放动画，一个播放完成后再播放下一个
  void _animateMenuItemAtIndex(int index) {
    if (index >= menuAnimationControllers.length) return;

    try {
      // 从0.0开始播放到1.0
      menuAnimationControllers[index].reset();
      menuAnimationControllers[index].forward().then((_) {
        // 当前动画播放完成后，间隔100ms播放下一个
        if (index < menuAnimationControllers.length - 1) {
          Timer(const Duration(milliseconds: 100), () {
            _animateMenuItemAtIndex(index + 1);
          });
        }
      });
    } catch (e) {
      // AnimationController 已被销毁时忽略错误
    }
  }
}
