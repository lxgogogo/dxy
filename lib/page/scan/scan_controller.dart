part of 'scan_screen.dart';

class ScanController extends GetxController {
  MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  StreamSubscription<Object?>? _subscription;
  String displayValue = '';

  @override
  void onReady() {
    _subscription = controller.barcodes.listen(onDetect);
    unawaited(controller.start());
    super.onReady();
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(controller.stop());
    controller.dispose();
    super.onClose();
  }

  Future<void> onDetect(BarcodeCapture barcodes) async {
    DebounceThrottle.throttle(() async {
      displayValue = barcodes.barcodes.first.displayValue ?? '';
      if (displayValue.isNotEmpty) {
        final player = AudioPlayer();
        player.setAsset(Assets.sounds.di);
        player.play();
        HapticFeedback.heavyImpact();
      }
    });
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
