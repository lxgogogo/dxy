
// 路由跳转工具类
import 'package:get/get.dart';

import '../utils/log_utils.dart';
import 'app_pages.dart';

class AppRoutesUtils {

  // 跳转视频详情
  static void jumpToVideo(int id) {
    LogUtils.printAll("跳转视频详情====");
    Get.toNamed(
      Routes.videoDetail,
      arguments: {'id': id},
    );
  }
}