part of 'search_child_view.dart';

class SearchChildController extends GetxController with GetSingleTickerProviderStateMixin {
  final SearchType type;

  SearchChildController(this.type);

  List<dynamic> get items {
    switch (type) {
      // case SearchType.news:
      //   return _buildNewsView(controller);
      case SearchType.video:
        return articles;
      case SearchType.book:
        return articles;
      case SearchType.course:
        return courses;
      case SearchType.tag:
        return tagItems;
      case SearchType.user:
        return userItems;
      // case SearchType.competition:
      //   return _buildCompetitionView(controller);
    }
  }

  List<ArticleBean> articles = [];
  List<CollectBean> courses = [];
  List<UserProfile> userItems = [];
  List<TagModel> tagItems = [];
  List<CompetitionBean> competitionItems = [];
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;
  ScrollController scrollController = ScrollController();
  StreamSubscription? eventSubscription;
  StreamSubscription? refreshNumEventObs;

  @override
  void onReady() {
    super.onReady();
    eventSubscription = EventBusUtil.of.on<EventRefreshSearchResult>().listen((event) {
      pageNum = 1;
      reqListData(showLoading: event.searchType == type);
    });
    reqListData();
    refreshNumEventObs = EventBusUtil.of.on<EventRefreshNum>().listen((event) {
      switch (type) {
        case SearchType.video:
          final index = articles.indexWhere((e) => e.id == event.id);
          if (index != -1) {
            articles[index].favoriteCount = event.favoriteCount;
            articles[index].likeCount = event.likeCount;
            articles[index].commentCount = event.commentCount;
            safeUpdate();
          }
          break;
        case SearchType.book:
        // TODO: Handle this case.
        case SearchType.course:
        // TODO: Handle this case.
        case SearchType.tag:
        // TODO: Handle this case.
        case SearchType.user:
        // TODO: Handle this case.
      }
    });
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    refreshNumEventObs?.cancel();
    super.dispose();
  }

  Future<void> reqListData({bool showLoading = false}) async {
    final keyword = SearchController.of.controller.text;
    Map<String, Object> params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'filters': {
        'categoryAlias': type.categoryAlias,
        'q': keyword.length > 200 ? keyword.substring(0, 200) : keyword,
      }
    };
    try {
      int recordsSize = 0;
      switch (type) {
        // case SearchType.news:
        case SearchType.video:
        case SearchType.book:
          await NetRequest().indexList(params, showLoading: showLoading, (data) {
            final dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              articles.clear();
            }
            articles.addAll(dataList);
          });
          break;
        case SearchType.course:
          await NetRequest().courseList(params, showLoading: showLoading, (data) {
            final dataList = List<CollectBean>.from(data['list'].map((article) => CollectBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              courses.clear();
            }
            courses.addAll(dataList);
          });
          break;
        case SearchType.user:
          await NetRequest()
              .userSearch(pageNum, pageSize, SearchController.of.controller.text, showLoading: showLoading, (data) {
            final userPageData = UserDataList.fromJson(data);
            recordsSize = userPageData.list?.length ?? 0;
            if (pageNum == 1) {
              userItems.clear();
            }
            userItems.addAll(userPageData.list ?? []);
          });
          break;
        case SearchType.tag:
          final res = await CommonService.of.tagIndex(
            pageNum: pageNum,
            pageSize: pageSize,
            keyword: keyword,
            isShowLoading: showLoading,
          );
          if (res.isSuccess) {
            final dataList = List<TagModel>.from(res.data['list'].map((e) => TagModel.fromJson(e)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              tagItems.clear();
            }
            tagItems.addAll(dataList);
          }
          break;
        // case SearchType.competition:
        //   await NetRequest().indexList(params, (data) {
        //     final dataList =
        //         List<CompetitionBean>.from(data['list'].map((article) => CompetitionBean.fromJson(article)));
        //     recordsSize = dataList.length;
        //     if (pageNum == 1) {
        //       competitionItems.clear();
        //     }
        //     competitionItems.addAll(dataList);
        //   });
        //   break;
      }
      if (pageNum == 1) {
        refreshController.refreshCompleted();
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.resetNoData();
        }
      } else {
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.loadComplete();
        }
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      isLoaded = true;
      if (pageNum == 1) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      }
      safeUpdate();
    }
  }

  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    reqListData();
  }

  void onFollowUser(int index) {
    UserStore.of.checkLogin(() {
      if (userItems[index].id == null) return;
      final followed = userItems[index].followed ?? false;
      NetRequest().followerToggle(userItems[index].id!, !followed, (data) {
        userItems[index].followed = !followed;
        safeUpdate();
      });
    });
  }
}
