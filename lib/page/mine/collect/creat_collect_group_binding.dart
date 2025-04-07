import 'package:get/get.dart';

import 'creat_collect_group_controller.dart';

class CreatCollectGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreatCollectGroupController());
  }
}
