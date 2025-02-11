import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/utils/toast_utils.dart';

class UserStore extends GetxController {
  static UserStore get of => Get.find();

  String get localUserStr => StorageService.of.getLocalUserStr();

  UserProfile get user => UserProfile.fromRawJson(localUserStr.isEmpty ? '{}' : localUserStr);

  bool isMe(int? otherUserId) {
    return otherUserId != null && otherUserId == user.id;
  }

  bool get isLogin => localUserStr.isNotEmpty;

  void checkLogin(VoidCallback callback) async {
    if (!isLogin) {
      ToastUtils.showToast('请先登录');
      Get.toNamed(Routes.login);
      return;
    }
    callback.call();
  }

  void initUserWithStorage() {
    if (!isLogin) return;
    // _userModel = userFromJsonString(localUserStr);
  }

  Future<void> clearUserStorage() async {
    // _userModel = null;
    await StorageService.of.putLocalUserStr('');
    await StorageService.of.putToken('');
  }
}