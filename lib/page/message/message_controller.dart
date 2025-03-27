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

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: MessageType.values.length,
      vsync: this,
    )..addListener(() {
        if (tabController.indexIsChanging) return;
        loadTabChild();
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

  void loadTabChild() {
    final childLogic = Get.find<MessageChildController>(tag: messageType.type);
    childLogic.onRefresh();
  }
}
