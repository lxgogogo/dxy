import 'package:get/get.dart';

extension SafeUpdateExtensions on GetxController {
  /// 安全刷新，防止页面销毁后数据请求返回后刷新界面
  void safeUpdate([List<Object>? ids, bool condition = true]) {
    if (isClosed) {
      return;
    }
    update(ids, condition);
  }
}
