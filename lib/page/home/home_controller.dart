part of 'home_screen.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  List<ArticleBean> videoItems = [];
  List<IndexCategory> courseItems = [];
  List<ArticleBean> bookItems = [];

  bool isShowHomeMenu = false;

  @override
  void onReady() {
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
