part of 'message_screen.dart';

class MessageController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  MessageType get messageType => MessageType.values[tabController.index];

  int get unReadCount =>
      switch (messageType) {
        MessageType.at => UserStore.of.badgeModel.value?.at,
        MessageType.comment => UserStore.of.badgeModel.value?.comment,
        MessageType.like => UserStore.of.badgeModel.value?.like,
        MessageType.favorite => UserStore.of.badgeModel.value?.favorite,
      } ??
      0;

  RxInt tabIndex = 0.obs;

  RxInt notifiesOfficial = 0.obs;
  RxInt notifiesPrivate = 0.obs;


  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: MessageType.values.length,
      vsync: this,
    )..addListener(() {
        if (tabController.indexIsChanging) return;
        loadTabChild(preMessageType: MessageType.values[tabIndex.value]);
        tabIndex.value = tabController.index;
      });
    for (final type in MessageType.values) {
      Get.lazyPut(() => MessageChildController(type), tag: messageType.type);
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadTabChild();
  }

  void messageReadAll() {
    if (unReadCount > 0) {
      final childLogic = Get.find<MessageChildController>(tag: messageType.type);
      childLogic.messageReadAll();
    }
  }

  void loadTabChild({MessageType? preMessageType}) {
    if (preMessageType != null) {
      final preChildLogic = Get.find<MessageChildController>(
        tag: preMessageType.type,
      );
      final markNeedReadCount = preChildLogic.items.where((e) => e.readStatus != 1).length;
      if (markNeedReadCount >= 0) {
        UserStore.of.refreshLocalBadge(
          markNeedReadCount,
          messageType: preMessageType,
        );
      }
    }

    final childLogic = Get.find<MessageChildController>(tag: messageType.type);
    childLogic.onRefresh();
  }

  void onFocusGained() {
    getNoticeBadge();
  }

  void getNoticeBadge() async {
    if (UserStore.of.isLogin) {
      final res =  await MessageService.noticeBadge();
      notifiesOfficial.value = res['notifiesOfficial'];
      notifiesPrivate.value = res['notifiesPrivate'];
    }
  }
}
