part of 'home_screen.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  List<ArticleBean> videoItems = [];
  List<IndexCategory> courseItems = [];
  List<ArticleBean> bookItems = [];
  List<VideoBean> hotVideos = [];
  bool isShowHomeMenu = false;

  @override
  void onReady() {
    loadHotVideos();
    loadVideos();
    loadCourses();
    loadBooks();
    super.onReady();
    scrollController.addListener(() {
      final isShow = scrollController.offset > (211.w + 24.w + 52.w + 24.w + 52.w - (12.w + 32.w + 12.w));
      if (isShowHomeMenu != isShow) {
        isShowHomeMenu = isShow;
        safeUpdate();
      }
    });
  }

  Future<void> loadVideos() async {
    await NetRequest().indexList(
      {
        'pageNum': 1,
        'pageSize': 4,
        'filters': {
          'categoryAlias': HomeType.video.categoryAlias,
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
   final params = {"id":[0,0,0,0],"size":4};
    if(hotVideos.isNotEmpty){
      params['id'] = hotVideos.map((e) => e.id).toList();
      params['size'] = hotVideos.length;
    }
    await NetRequest().hotVideo(
      params,
      showLoading: false,
      (data) {
        final items = List<VideoBean>.from(
          data.map((article) => VideoBean.fromMap(article)),
        );

        if (items.isNotEmpty) {
          hotVideos.assignAll(items);
          safeUpdate();
        }
      },
    );
  }

  void toVideoList() {}

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
}
