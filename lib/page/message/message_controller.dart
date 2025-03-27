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

  int? get unReadCount => switch (messageType) {
        MessageType.at => MainController.of.badgeModel.value?.at,
        MessageType.comment => MainController.of.badgeModel.value?.comment,
        MessageType.like => MainController.of.badgeModel.value?.like,
        MessageType.favorite => MainController.of.badgeModel.value?.favorite,
      };

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: MessageType.values.length,
      vsync: this,
    );
  }

  void messageReadAll() {
    if ((unReadCount ?? 0) > 0) {
      final childController = childControllers[tabController.index];
      childController.messageReadAll();
    } else {
      ToastUtils.showToast('全部已读');
    }
  }
}
