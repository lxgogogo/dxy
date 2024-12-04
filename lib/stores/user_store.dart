import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:oktoast/oktoast.dart';

class UserStore extends GetxController {
  static UserStore get of => Get.find();

  String get localUserStr => StorageService.of.getLocalUserStr();

  UserProfile get user =>
      UserProfile.fromRawJson(localUserStr.isEmpty ? '{}' : localUserStr);

  bool get isLogin => localUserStr.isNotEmpty;

  void checkLogin(VoidCallback callback) async {
    if(!isLogin) {
      showToast('请先登录',duration: const Duration(seconds: 2));
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
    await StorageService.of.putLocalUserStr('');
  }
}

extension UserStoreFunc on UserStore {
  bool isMe(String? otherUserId) {
    return false;
    // return otherUserId?.isNotEmpty == true && otherUserId == userId;
  }
}
