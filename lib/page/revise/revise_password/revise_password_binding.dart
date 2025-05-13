import 'package:get/get.dart';

import 'revise_password_controller.dart';

class RevisePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RevisePasswordController());
  }
}
