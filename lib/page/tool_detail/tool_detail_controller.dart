part of 'tool_detail_screen.dart';

class ToolDetailController extends GetxController {
  int? id;

  ArticleDetailBean? detailBean;
  List<CommentBean>? comments = [];

  bool loaded = false;

  StreamSubscription? eventSubscription;

  bool noNetwork = false;

  final RefreshController refreshController = RefreshController();
  int pageNum = 1;
  int pageSize = 10;
  bool noMore = false;

  @override
  void onInit() {
    id = Get.arguments as int?;
    super.onInit();
    eventSubscription = EventBusUtil.of.on<EventRefreshComments>().listen((event) {
      onRefresh();
    });
    dataInit();
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestDetail(showLoading: false);
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      ToastUtils.showToast('请检查网络');
      return;
    }
    requestDetail();
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    super.onClose();
  }

  requestDetail({bool showLoading = true}) {
    NetRequest().contentShow({'id': id}, showLoading: showLoading, (data) {
      if (data == null) {
        ToastUtils.showToast('该工具已删除');
        Get.back();
        return;
      }
      detailBean = ArticleDetailBean.fromJson(data);
      loaded = true;
      safeUpdate();
      EventBusUtil.of.fire(EventRefreshNum(
        detailBean!.id!,
        commentCount: detailBean?.commentCount,
        likeCount: detailBean?.likeCount,
        favoriteCount: detailBean?.favoriteCount,
        viewCount: detailBean?.viewCount,
      ));
    });

    onRefresh();
  }

  void onRefresh() async {
    pageNum = 1;
    loadComments();
  }

  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    loadComments();
  }

  loadComments() async {
    try {
      int recordsSize = 0;
      await NetRequest().commentList(
        {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'filters': {
            'relType': 'content',
            'relId': id,
          },
        },
        showLoading: false,
        (data) {
          final dataList = List<CommentBean>.from(
            data['list'].map((comment) => CommentBean.fromJson(comment)),
          );
          recordsSize = dataList.length;
          if (pageNum == 1) {
            comments = dataList;
          }
          comments?.addAll(dataList);
          safeUpdate();
        },
      );
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
      safeUpdate();
    }
  }
}
