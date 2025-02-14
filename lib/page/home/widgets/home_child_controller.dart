part of 'home_child_view.dart';

class HomeChildController extends GetxController with GetSingleTickerProviderStateMixin {
  final HomeType type;

  HomeChildController(this.type);

  List<BannerBean> banners = [];
  List<CompetionLoopBean> loops = [];
  List<ArticleBean> articles = [];

  List<ArticleBean> bookSuggests = [];

  List<IndexCategory> categories = [];
  int categorySel = 0;
  int? categoryId;
  List<CourseBean> courses = [];

  int pageNum = 1;
  bool noMore = false;
  final RefreshController refreshController = RefreshController();

  final ScrollController listController = ScrollController();

  StreamSubscription? networkSubscription;
  StreamSubscription? eventSubscription;

  @override
  void onReady() {
    super.onReady();
    networkSubscription = Connectivity().onConnectivityChanged.listen((events) {
      if (!events.contains(ConnectivityResult.none)) {
        loadData();
      }
    });
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      loadData();
    });
    loadData();
  }

  @override
  void onClose() {
    networkSubscription?.cancel();
    eventSubscription?.cancel();
    super.dispose();
  }

  void loadData({bool showLoading = false}) {
    if (showLoading) {
      EasyLoading.show(status: 'loading...');
    }
    Future.wait([
      reqListData(),
      reqOtherData(),
    ]).whenComplete(() {
      if (showLoading) {
        EasyLoading.dismiss();
      }
    });
  }

  Future<void> reqOtherData() async {
    if (type == HomeType.news) {
      await Future.wait([
        loadBanners(),
        loadLoops(),
      ]);
    } else if (type == HomeType.book) {
      await loadBookSuggest(showLoading: false);
    } else if (type == HomeType.course) {
      await loadCourseTabs();
    }
  }

  Future<void> loadBanners() async {
    await NetRequest().indexBanner({'pos': 'index.banner', 'type': '1'}, showLoading: false, (data) {
      banners = List<BannerBean>.from(data.map((banner) => BannerBean.fromJson(banner)));
      safeUpdate();
    });
  }

  Future<void> loadLoops() async {
    await NetRequest().competitionLoop({}, showLoading: false, (data) {
      loops = List<CompetionLoopBean>.from(data.map((loop) => CompetionLoopBean.fromJson(loop)));
      safeUpdate();
    });
  }

  Future<void> loadBookSuggest({bool showLoading = true}) async {
    await NetRequest().bookRecommend({"pageSize": 4}, showLoading: showLoading, (data) {
      bookSuggests = List<ArticleBean>.from(data.map((article) => ArticleBean.fromJson(article)));
      safeUpdate();
      safeUpdate();
    });
  }

  Future<void> loadCourseTabs() async {
    await NetRequest().courseCategory({"parentAlias": "course", "parentId": 1}, showLoading: false, (data) {
      List<IndexCategory> categoryList =
          List<IndexCategory>.from(data.map((category) => IndexCategory.fromJson(category)));
      categoryList.insert(0, IndexCategory(name: '全部'));
      categories = categoryList;
      safeUpdate();
    });
  }

  Future<void> reqListData() async {
    Map<String, Object> params = {
      'pageNum': pageNum,
      'pageSize': 20,
      'filters': {
        'categoryAlias': type.categoryAlias,
        if (type == HomeType.course && categoryId != null) 'categoryId': categoryId,
      }
    };
    try {
      int recordsSize = 0;
      switch (type) {
        case HomeType.news:
        case HomeType.video:
        case HomeType.book:
          await NetRequest().indexList(params, showLoading: false, (data) {
            final dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              articles.clear();
            }
            articles.addAll(dataList);
          });
          break;
        case HomeType.course:
          await NetRequest().courseList(params, showLoading: false, (data) {
            List<CourseBean> dataList =
                List<CourseBean>.from(data['list'].map((course) => CourseBean.fromJson(course)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              courses.clear();
            }
            courses.addAll(dataList);
          });
          break;
      }
      if (pageNum == 1) {
        refreshController.refreshCompleted();
        if (recordsSize < 20) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.resetNoData();
        }
      } else {
        if (recordsSize < 20) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.loadComplete();
        }
      }
    } catch (e) {
      if (pageNum == 1) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      safeUpdate();
    }
  }

  Future<void> onRefresh() async {
    pageNum = 1;
    loadData();
  }

  Future<void> onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    reqListData();
  }
}
