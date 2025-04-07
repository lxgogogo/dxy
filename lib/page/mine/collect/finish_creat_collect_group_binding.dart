import 'package:get/get.dart';

import 'finish_creat_collect_group_controller.dart';

class FinishCreatCollectGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FinishCreatCollectGroupController());
  }
}
