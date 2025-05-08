import 'dart:async';
import 'package:get/get.dart';

mixin StayReportGetxMixin on GetxController {
  Timer? _stayTimer;
  bool _hasReportedStay = false;

  @override
  void onInit() {
    startStayReportTimer();
    super.onInit();
  }

  /// 启动监听（建议在 onInit 或 onReady 中调用）
  void startStayReportTimer() {
    _stayTimer = Timer(const Duration(minutes: 1), () {
      if (!_hasReportedStay) {
        _hasReportedStay = true;
        onStayReported();
      }
    });
  }

  /// 埋点上报逻辑（子类必须实现）
  void onStayReported();

  /// 重置定时器（可用于页面刷新等场景）
  void resetStayReportTimer() {
    _stayTimer?.cancel();
    _hasReportedStay = false;
    startStayReportTimer();
  }

  @override
  void onClose() {
    _stayTimer?.cancel();
    super.onClose();
  }
}
