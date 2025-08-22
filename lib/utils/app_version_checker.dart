import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/app_version.dart';
import '../services/index.dart';
import '../widget/dialog_common.dart';

class AppVersionChecker {
  static final AppVersionChecker of = AppVersionChecker._();

  AppVersionChecker._();

  bool isVersionInCheck = false;

  String? _ignoredVersion; // 内存中保存忽略的版本号

  Future<void> checkVersion({bool showTips = false, bool showLoading = false}) async {
    if (isVersionInCheck) return;
    isVersionInCheck = true;
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    try {
      final res = await CommonService.of.appVersion(showLoading: showLoading);
      if (res.isSuccess) {
        final appVersion = AppVersion.fromJson(res.data);
        final latestVersion = Platform.isAndroid ? appVersion.androidVersion : appVersion.iosVersion;

        if (latestVersion?.isNotEmpty == true) {
          if (latestVersion!.compareTo(currentVersion) > 0) {
            final forceUpdate = appVersion.forced ?? false;

            // 非强制更新时，如果忽略过该版本或更低版本，直接跳过
            if (!forceUpdate && _ignoredVersion != null && latestVersion.compareTo(_ignoredVersion!) <= 0) {
              return;
            }

            if (Get.context == null) return;

            await showDialog(
              barrierDismissible: false,
              context: Get.context!,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: CommonDialog(
                  title: '德学院APP更新说明',
                  contentWidget: Text(
                    appVersion.description ?? '',
                    style: TextStyle(
                      color: '#666666'.hexColor,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  confirmText: '立即更新',
                  cancelText: '下次再说',
                  showClose: false,
                  onlyConfirm: forceUpdate,
                  onConfirm: () {
                    // if (!forceUpdate) Navigator.of(context).pop();
                    var url = '';
                    if (Platform.isAndroid) {
                      url = appVersion.androidUrl!;
                    } else {
                      url = appVersion.iosUrl!;
                    }
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  onCancel: () {
                    if (!forceUpdate) {
                      _ignoredVersion = latestVersion; // 只在内存中记录
                    }
                  },
                ),
              ),
            );
          } else {
            if (!showTips) return;
            DialogUtil.showToast('当前已经是最新版本');
          }
        } else {
          if (!showTips) return;
          DialogUtil.showToast('当前已经是最新版本');
        }
      } /* else {
        DialogUtil.showToast(res.msg);
      }*/
    } finally {
      isVersionInCheck = false;
    }
  }
}
