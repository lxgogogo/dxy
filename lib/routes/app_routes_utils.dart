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
          builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: CommonDialog(
                    title: title,
                    content: content,
                    confirmText: '好',
                    onlyConfirm: true,
                    showClose: false,
                    onConfirm: () {
                      Get.close(1);
                      Get.toNamed(Routes.login);
                    }),
              ));
      return false;
    }
    return true;
  }

  // 是否有下载书籍权限
  static bool haveDownLoadBook(bool haveDown) {
    if (!haveLogin(title: '请登录后下载', content: '您当前的身份为访客\n登录后即可下载书籍')) {
      return false;
    } else if (!haveDown) {
      String powerName = UserStore.of.user?.userLevel?.name ?? '';
      if (powerName.isEmpty) {
        powerName = '一般用户';
      }
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) => CommonDialog(
                title: '当前下载书籍已达上限',
                content: '您当前的身份为$powerName\n请提升用户等级获得更多权限',
                confirmText: '好',
                showClose: false,
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
    String powerName = UserStore.of.user?.userLevel?.name ?? '';
    if (powerName.isEmpty) {
      powerName = '一般用户';
    }
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
              title: '当前收藏内容已达上限',
              content: '您当前的身份为$powerName\n请提升用户等级获得更多权限',
              confirmText: '好',
              showClose: false,
              onConfirm: () {
                Get.close(1);
                Get.toNamed(Routes.equityCenter);
              },
              cancelText: '取消',
            ));
  }

  // 观看视频权限
  static void haveVideoWatch({String title = '当前观看视频已达上限'}) {
    String powerName = UserStore.of.user?.userLevel?.name ?? '';
    if (powerName.isEmpty) {
      powerName = '一般用户';
    }
    String content = '您当前的身份为$powerName\n请提升用户等级获得更多权限';
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
              title: title,
              content: content,
              confirmText: '好',
              showClose: false,
              onConfirm: () {
                Get.toNamed(Routes.equityCenter);
              },
              cancelText: '取消',
            ));
  }

  static void toDetail(String? contentType, int? contentId) {
    if (contentType == null || contentId == null) return;
    if (contentType == 'book') {
      Get.toNamed(Routes.bookDetail, arguments: contentId);
    } else if (contentType == 'article') {
      Get.toNamed(Routes.articleDetail, arguments: contentId);
    } else if (contentType == 'tool') {
      Get.toNamed(Routes.toolDetail, arguments: contentId);
    } else if (contentType == 'video' || contentType == 'videoList') {
      Get.toNamed(Routes.videoDetail, arguments: {'id': contentId});
    } else if (contentType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: contentId);
    }
  }
}
