import 'package:get/get.dart';

import 'message_notice_controller.dart';

class Message_noticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Message_noticeController());
  }
}
