import 'package:get/get.dart';

import 'message_notice_detail_controller.dart';

class MessageNoticeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MessageNoticeDetailController());
  }
}
