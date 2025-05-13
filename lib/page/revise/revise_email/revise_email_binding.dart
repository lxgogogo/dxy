import 'package:get/get.dart';

import 'revise_email_controller.dart';

class ReviseEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviseEmailController());
  }
}
