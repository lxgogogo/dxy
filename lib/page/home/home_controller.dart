part of 'home_screen.dart';

class HomeController extends GetxController {
  double pixels = 0;

  final ScrollController scrollController = ScrollController();

  void setPixels(double p) {
    pixels = p;
    safeUpdate();
  }

  List<ArticleBean> videoItems = [];
  List<IndexCategory> courseItems = [];
  List<ArticleBean> bookItems = [];

  @override
  void onReady() {
    loadVideos();
    loadCourses();
    loadBooks();
    super.onReady();
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
