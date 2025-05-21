import 'package:get/get.dart';

import 'revise_name_controller.dart';

class ReviseNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviseNameController());
  }
}
