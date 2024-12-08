part of 'article_detail_screen.dart';

class ArticleDetailController extends GetxController {
  int? id;

  ArticleDetailBean? detailBean;
  List<CommentBean>? comments;

  bool loaded = false;

  StreamSubscription? eventSubscription;

  @override
  void onInit() {
    id = Get.arguments as int?;
    super.onInit();
    requestDetail();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail();
    });
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    super.onClose();
  }

  requestDetail() {
    NetRequest().contentShow({'id': id}, (data) {
      if (data == null) {
        showToast('该文章已删除');
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
    }, (data) {
      List<CommentBean> dataList = List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
      comments = dataList;
      safeUpdate();
    });
  }
}
