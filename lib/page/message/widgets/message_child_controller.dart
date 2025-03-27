part of 'message_child_view.dart';

class MessageChildController extends GetxController {
  final MessageType messageType;

  MessageChildController(this.messageType);

  bool loaded = false;
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;

  List<MessageBean> items = [];
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription? refreshEvent;

  void _onRefresh() async {
    pageNum = 1;
    reqListData(showLoading: false);
  }

  void _onLoading() async {
    pageNum++;
    reqListData(showLoading: false);
  }

  @override
  void onReady() {
    super.onReady();
    reqListData();
    refreshEvent = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      reqListData(showLoading: false);
    });
  }

  @override
  void onClose() {
    refreshEvent?.cancel();
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> reqListData({bool showLoading = false}) async {
    try {
      int recordsSize = 0;
      await NetRequest().messageList(
        {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'filters': {
            'type': messageType.type,
          },
        },
        showLoading: false,
        (data) {
          MessageList dataList = MessageList.fromJson(data);
          recordsSize = dataList.list?.length ?? 0;
          if (pageNum == 1) {
            items.clear();
          }
          items.addAll(dataList.list ?? []);
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
      loaded = true;
      if (pageNum == 1) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      }
      safeUpdate();
    }
  }

  Future<void> messageReadAll() async {
    try {
      final res = await CommonService.of.messageReadAll(messageType.type);
      if (res.isSuccess) {
        ToastUtils.showToast('全部已读');
        for (final item in items) {
          item.readStatus = 1;
        }
        safeUpdate();
      }
    } catch (e) {}
  }
}
