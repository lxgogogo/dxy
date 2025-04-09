import 'package:get/get.dart';

import 'equity_center_controller.dart';

class EquityCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EquityCenterController());
  }
}
