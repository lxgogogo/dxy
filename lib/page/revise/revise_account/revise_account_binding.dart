import 'package:get/get.dart';

import 'revise_account_controller.dart';

class ReviseAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviseAccountController());
  }
}
