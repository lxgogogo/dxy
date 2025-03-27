part of 'message_screen.dart';

class MessageController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  List<MessageChildController> childControllers = [
    MessageChildController(MessageType.at),
    MessageChildController(MessageType.comment),
    MessageChildController(MessageType.like),
    MessageChildController(MessageType.favorite),
  ];

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
    );
  }

  void messageReadAll() {
    final childController = childControllers[tabController.index];
    childController.messageReadAll();
  }
}
