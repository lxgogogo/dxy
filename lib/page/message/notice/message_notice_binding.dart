import 'package:get/get.dart';

import 'message_notice_controller.dart';

class MessageNoticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MessageNoticeController());
  }
}
