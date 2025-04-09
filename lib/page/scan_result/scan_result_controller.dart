part of 'scan_result_screen.dart';

class ScanResultController extends GetxController {
  /// 二维码是否有效
  bool isValid = false;

  /// 是否授权成功
  bool isSuccess = false;

  @override
  void onInit() {
    isValid = Get.arguments?['isValid'] as bool? ?? false;
    super.onInit();
  }

  Future<void> onConfirm() async {
    final uuid = Get.arguments?['uuid'] as String? ?? '';
    if (uuid.isNotEmpty) {
      final res = await LoginService.of.confirmLoginCode(
        uuid: uuid,
      );
      isSuccess = res.isSuccess;
      safeUpdate();
    }
  }
}
