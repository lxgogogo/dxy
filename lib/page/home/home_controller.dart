part of 'home_screen.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
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

  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    super.onInit();
  }

  void loadData() {
    loadBanners();
    loadHotVideos();
    loadCourseGroup();
    loadOldCourses();
    loadBooks();
    loadHotTags();
    if (UserStore.of.isLogin) {
      UserStore.of.getUserInfo();
    }
  }

  bool hasNetwork = false;

  @override
  Future<void> onReady() async {
    super.onReady();
    final result = await Connectivity().checkConnectivity();
    hasNetwork = !result.contains(ConnectivityResult.none);
    if (hasNetwork) loadData();
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
        loadData();
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
  }

  @override
  void onClose() {
    animationController.dispose();
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

  void loadHotTags() async {
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

  Future<void> loadCourseGroup({bool needResetGroup = false}) async {
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
    final res = await CourseService.of.courseIndex(
      type,
      pageNum: 1,
      pageSize: 3,
    );
    if (res.isSuccess) {
      final listRes = res.data?['list'] as List? ?? [];
      final records = listRes.map((e) => CourseModel.fromJson(e)).toList();
      courseItems.assignAll(records.take(2));
      final des = courseGroup?.value?.des;
      if (des == 'knowledge') {
        for (final item in courseItems) {
          final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
          if (knowledgeIndexDtoList.isNotEmpty) {
            final startIndex = knowledgeIndexDtoList.indexWhere((e) => e.status == 0);
            if (startIndex != -1) {
              knowledgeIndexDtoList[startIndex].isSelected = true;
            } else {
              knowledgeIndexDtoList.first.isSelected = true;
            }
          }
        }
      }
      safeUpdate();
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
    }
  }

  void onIndexChanged(int value) {
    bannerIndex = value;
  }

  changeMainTab(int i) {
    Get.find<MainController>().onTabBarItem(1);
  }

  void tagOnTap(value) async {
    DialogUtil.showLoading();
    tagId = value.id ?? 0;
    await loadVideos();
    DialogUtil.dismiss();
  }

  Future<void> toKnowledge(CourseModel item) async {
    final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
    final knowledgeIndexDto = knowledgeIndexDtoList.firstWhereOrNull((e) => e.isSelected);
    if (knowledgeIndexDto == null) {
      return;
    }
    int? contentId;
    int? subContentId;
    String? contentType;
    if (knowledgeIndexDto.contentVideo != null) {
      contentId = knowledgeIndexDto.contentVideo!.id;
      subContentId = knowledgeIndexDto.contentVideo!.listId;
      contentType = subContentId != null ? 'videoList' : 'video';
    } else if (knowledgeIndexDto.contentArticle != null) {
      contentId = knowledgeIndexDto.contentArticle!.id;
      contentType = 'article';
    }
    if (knowledgeIndexDto.status == 1) {
      AppRoutesUtils.toDetail(
        contentType,
        contentId,
        subContentId: subContentId,
      );
    } else {
      try {
        final res = await CourseService.of.courseRead(knowledgeIndexDto.id);
        if (res.isSuccess) {
          AppRoutesUtils.toDetail(
            contentType,
            contentId,
            subContentId: subContentId,
          );
        } else {
          DialogUtil.showToast(res.msg);
        }
      } catch (e) {
        Log.e(e.toString());
      }
    }
  }

  void onSelectKnowledgeItem(int index, int childIndex) {
    final knowledgeIndexDtoList = courseItems[index].knowledgeIndexDtoList ?? [];
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
      item.completed = (item.completed ?? 0)+1;
      safeUpdate();
    }, errorBack: () {
      loadCourses();
      safeUpdate();
    });
  }

  void endFunction(value) {
    if (value == true) {
      loadCourses();
    }
  }
}
