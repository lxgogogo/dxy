import 'package:get/get.dart';

import 'revise_phone_controller.dart';

class RevisePhoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RevisePhoneController());
  }
}
