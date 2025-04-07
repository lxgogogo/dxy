import 'package:get/get.dart';

import 'collect_list_controller.dart';

class CollectListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CollectListController());
  }
}
