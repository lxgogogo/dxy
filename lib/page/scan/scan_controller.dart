part of 'scan_screen.dart';

class ScanController extends GetxController {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
  );
  String displayValue = '';

  @override
  void onReady() {
    unawaited(controller.start());
    super.onReady();
  }

  @override
  void onClose() {
    unawaited(controller.stop());
    controller.dispose();
    super.onClose();
  }

  Future<void> onDetect(BarcodeCapture barcodes) async {
    displayValue = barcodes.barcodes.first.displayValue ?? '';
    if (displayValue.isNotEmpty) {
      final player = AudioPlayer();
      player.setAsset(Assets.sounds.di);
      player.play();

      final res = await LoginService.of.queryLoginCode(
        uuid: displayValue,
      );
      if (res.isSuccess) {
        final isValid = res.data as bool? ?? false;
        Get.toNamed(Routes.scanResult, arguments: {
          'uuid': displayValue,
          'isValid': isValid,
        });
      } else {
        ToastUtils.showToast(res.msg);
      }
    }
  }

  Future<void> pickImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final barcodeCapture = await controller.analyzeImage(xFile.path);
      if (barcodeCapture != null) {
        onDetect(barcodeCapture);
      }
    }
  }
}
