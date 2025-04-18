part of 'home_screen.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  List<BannerBean> banners = [];
  List<ArticleBean> videoItems = [];
  List<IndexCategory> courseItems = [];
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

  @override
  void onReady() {
    loadBanners();
    loadHotVideos();
    loadCourses();
    loadBooks();
    loadHotTags();
    super.onReady();
    scrollController.addListener(() {
      final isShow = scrollController.offset > (211.w + 24.w + 52.w + 24.w + 52.w - (12.w + 32.w + 12.w));
      if (isShowHomeMenu != isShow) {
        isShowHomeMenu = isShow;
        safeUpdate();
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
        'filters': {
          'categoryAlias': HomeType.video.categoryAlias,
          'sort': 'popular',
          'tagId' : tagId
        }
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

  void loadHotTags() async  {
    tagList = await HomeService.queryTopHeatTag({
      'pageNum': 1,
      'pageSize': 100
    });
    tagId = tagList[0].id ?? 0;
    loadVideos();
    safeUpdate();
  }

  void toVideoList() {
    Get.toNamed(Routes.videoList);
  }

  Future<void> loadCourses() async {
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
          courseItems.assignAll(items);
          safeUpdate();
        }
      },
    );
  }

  Future<void> loadBooks({bool showLoading = true}) async {
    await NetRequest().bookRecommend({"pageSize": 4}, showLoading: showLoading, (data) {
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
    EasyLoading.show(status: '加载中......');
    tagId = value.id ?? 0;
    await loadVideos();
    EasyLoading.dismiss();
  }
}
