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

  StreamSubscription? tabEvent;
  StreamSubscription? refreshEvent;

  void onRefresh() async {
    pageNum = 1;
    loadData();
  }

  void onLoading() async {
    pageNum++;
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    tabEvent = EventBusUtil.of.on<EventChangeMainTab>().listen((event) {
      if (event.tabIndex == 2) {
        loadData();
      }
    });
    refreshEvent = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      onRefresh();
    });
  }

  @override
  void onClose() {
    tabEvent?.cancel();
    refreshEvent?.cancel();
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      int recordsSize = 0;
      await Future.wait(
        [
          NetRequest().messageList(
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
          ),
          if (pageNum == 1) UserStore.of.refreshBadge(),
        ],
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
        ToastUtils.showToast('消息已变更为已读！');
        for (final item in items) {
          item.readStatus = 1;
        }
        safeUpdate();
        UserStore.of.refreshBadge();
      }
    } catch (e) {}
  }
}
