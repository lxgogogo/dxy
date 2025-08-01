import 'package:get/get.dart';

import 'points_conversion_controller.dart';

class PointsConversionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PointsConversionController());
  }
}
