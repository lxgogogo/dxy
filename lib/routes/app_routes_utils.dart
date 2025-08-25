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
                    confirmText: '登录/注册',
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
    if (!haveLogin(title: '请登录后下载', content: '您当前的身份为访客\n登录/注册后即可下载书籍')) {
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
  static void haveVideoWatch({int featured = 0}) {
    String title = '当前观看视频已达上限';
    String content = '您当前的身份为访客，请登录/注册后观看';
    if (UserStore.of.isLogin) {
      String powerName = UserStore.of.user?.userLevel?.name ?? '';
      if (powerName.isEmpty) {
        powerName = '一般用户';
      }
      if (featured == 1) {
        title = '当前观看精选视频已达上限';
      }
      content = '您当前的身份为$powerName\n请提升用户等级获得更多权限';
    }

    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
            title: title,
            content: content,
            onlyConfirm: true,
            confirmText: '好',
            showClose: false,
            onConfirm: () {
              Get.close(0);
              Get.toNamed(Routes.equityCenter, arguments: {'backHome': true});
            }));
  }

  static Future<T?>? toDetail<T>(
    String? contentType,
    int? contentId, {
    int? subContentId,
    Function? callBack,
    Duration? duration,
  }) {
    if (contentType == null || contentId == null) return null;
    if (contentType == 'book') {
      return Get.toNamed(Routes.bookDetail, arguments: contentId)?.then((value) {
        if (callBack != null) {
          callBack(value);
        }
        return null;
      });
    } else if (contentType == 'article') {
      return Get.toNamed(Routes.articleDetail, arguments: contentId)?.then((value) {
        if (callBack != null) {
          callBack(value);
        }
        return null;
      });
    } else if (contentType == 'tool') {
      return Get.toNamed(Routes.toolDetail, arguments: contentId)?.then((value) {
        if (callBack != null) {
          callBack(value);
        }
        return null;
      });
    } else if (contentType == 'video' || contentType == 'videoList') {
      return Get.toNamed(Routes.videoDetail, arguments: {
        'id': contentId,
        'childId': subContentId,
        'duration': duration,
      })?.then((value) {
        if (callBack != null) {
          callBack(value);
        }
        return null;
      });
    } else if (contentType == 'thread') {
      return Get.toNamed(Routes.feedDetail, arguments: contentId)?.then((value) {
        if (callBack != null) {
          callBack(value);
        }
        return null;
      });
    }
    return null;
  }
}
