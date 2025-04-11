
// 路由跳转工具类
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../stores/user_store.dart';
import '../utils/log_utils.dart';
import '../widget/dialog_common.dart';
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

  // 是否有登录权限
  static bool haveLogin({String title = '', String content = ''}) {
    if (!UserStore.of.isLogin) {
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) => CommonDialog(
            title: title,
            content: content,
            confirmText: '好',
            onlyConfirm: true,
            onConfirm: () {
              Get.close(1);
              Get.toNamed(Routes.login);
            }
          ));
      return false;
    }
    return true;
  }

  // 是否有下载书籍权限
  static bool haveDownLoadBook(bool haveDown) {
    if (!haveLogin(title: '当前下载书籍已达上限',
        content: '您当前的身份为一般用户\n请提升用户等级获得更多权限')) {
      return false;
    } else if (!haveDown) {
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) => CommonDialog(
            title: '当前下载书籍已达上限',
            content: '您当前的身份为一般用户\n请提升用户等级获得更多权限',
            confirmText: '好',
            onConfirm: () {
              Get.close(1);
              Get.toNamed(Routes.equityCenter);
            },
            cancelText: '取消',
          ));
      return false;
    }
    return true;
  }

  // 收藏权限
  static void haveCollect() {
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
          title: '当前收藏内容已达上限',
          content: '您当前的身份为一般用户\n请提升用户等级获得更多权限',
          confirmText: '好',
          onConfirm: () {
            Get.close(1);
            Get.toNamed(Routes.equityCenter);
          },
          cancelText: '取消',
        ));
  }

  static void haveVideoWatch({
    String title = '当前观看视频已达上限',
    String content = '您当前的身份为一般用户\n请提升用户等级获得更多权限'}) {
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
          title: title,
          content: content,
          confirmText: '好',
          onConfirm: () {
            Get.toNamed(Routes.equityCenter);
          },
          cancelText: '取消',
        ));
  }


}