part of 'article_detail_screen.dart';

class ArticleDetailController extends GetxController {
  int? id;

  ArticleDetailBean? detailBean;
  List<CommentBean>? comments;

  bool loaded = false;

  StreamSubscription? eventSubscription;

  bool noNetwork = false;

  @override
  void onInit() {
    id = Get.arguments as int?;
    super.onInit();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail(showLoading: false);
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
        ToastUtils.showToast('该文章已删除');
        Get.back();
        return;
      }
      detailBean = ArticleDetailBean.fromJson(data);
      loaded = true;
      safeUpdate();
    });

    NetRequest().commentList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {'relType': 'content', 'relId': id}
    }, showLoading: showLoading, (data) {
      List<CommentBean> dataList = List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
      comments = dataList;
      safeUpdate();
    });
  }
}
