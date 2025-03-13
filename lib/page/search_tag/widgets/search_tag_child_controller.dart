part of 'search_tag_child_view.dart';

class SearchTagChildController extends GetxController with GetSingleTickerProviderStateMixin {
  final SearchTagType type;
  final TagModel? tagModel;

  SearchTagChildController(
    this.type,
    this.tagModel,
  );

  List<ArticleBean> articles = [];
  List<CollectBean> courses = [];
  List<BoardBean> feeds = [];

  final RefreshController refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;

  @override
  void onReady() {
    super.onReady();
    reqListData();
  }

  Future<void> reqListData({bool showLoading = false}) async {
    Map<String, dynamic> params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      if (type == SearchTagType.feed) ...{
        'ordered': NetRequest.BOARD_SORT_TIME,
      },
      'filters': {
        if (type != SearchTagType.feed) ...{
          'categoryAlias': type.categoryAlias,
        },
        'tagId': tagModel?.id,
      },
    };
    try {
      int recordsSize = 0;
      switch (type) {
       case SearchTagType.news:
        case SearchTagType.video:
        case SearchTagType.book:
          await NetRequest().indexList(params, (data) {
            final dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              articles.clear();
            }
            articles.addAll(dataList);
          });
          break;
        case SearchTagType.course:
          await NetRequest().courseList(params, (data) {
            final dataList = List<CollectBean>.from(data['list'].map((article) => CollectBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              courses.clear();
            }
            courses.addAll(dataList);
          });
        case SearchTagType.feed:
          await NetRequest().getThreadListByBoard(params, (data) {
            final dataList = List<BoardBean>.from(data['list'].map((article) => BoardBean.fromJson(article)));
            recordsSize = dataList.length;
            if (pageNum == 1) {
              feeds.clear();
            }
            feeds.addAll(dataList);
          });
          break;
      }
      if (recordsSize < pageSize) {
        noMore = true;
        refreshController.loadNoData();
      } else {
        noMore = false;
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      isLoaded = true;
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
}
