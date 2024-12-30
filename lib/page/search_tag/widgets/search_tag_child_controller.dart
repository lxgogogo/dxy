part of 'search_tag_child_view.dart';

class SearchTagChildController extends GetxController with GetSingleTickerProviderStateMixin {
  final SearchTagType type;

  SearchTagChildController(this.type);

  List<ArticleBean> articles = [];
  List<CollectBean> courses = [];

  final RefreshController refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;

  int? tagId;

  @override
  void onInit() {
    tagId = Get.arguments?['tagId'] as int?;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    reqListData();
  }

  Future<void> reqListData({bool showLoading = false}) async {
    Map<String, dynamic> params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'filters': {
        'categoryAlias': type.categoryAlias,
        'tagId': tagId,
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
