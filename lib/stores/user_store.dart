import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/utils/toast_utils.dart';

import '../model/message_badge_model.dart';
import '../services/index.dart';
import '../utils/net_request.dart';

class UserStore extends GetxController {
  static UserStore get of => Get.find();

  String get localUserStr => StorageService.of.getLocalUserStr();

  final _user = Rx<UserProfile?>(null);

  UserProfile? get user => _user.value ?? UserProfile.fromRawJson(localUserStr.isEmpty ? '{}' : localUserStr);

  bool isMe(int? otherUserId) {
    return otherUserId != null && otherUserId == user?.id;
  }

  bool get isLogin => localUserStr.isNotEmpty;

  void checkLogin(VoidCallback callback) async {
    if (!isLogin) {
      //ToastUtils.showToast('请先登录');
      Get.toNamed(Routes.login);
      return;
    }
    callback.call();
  }

  Future<void> clearUserStorage() async {
    await StorageService.of.putLocalUserStr('');
    await StorageService.of.putToken('');
    _user.value = null;
    refreshBadge();
  }

  Future<void> putUserInfo(UserProfile user) async {
    await StorageService.of.putLocalUserStr(user.toRawJson());
    _user.value = user;
    refreshBadge();
  }

  Future<void> getUserInfo() async {
    await NetRequest().getUserInfo((data) async {
      final user = UserProfile.fromJson(data);
      await StorageService.of.putLocalUserStr(user.toRawJson());
      _user.value = user;
    }, (errorMsg) {});
  }

  Future<void> updateUserInfo(Map<String, dynamic> json) async {
    _user.value = UserProfile.fromJson({
      ..._user.value?.toJson() ?? {},
      ...json,
    });
    await StorageService.of.putLocalUserStr(_user.value!.toRawJson());
  }

  /// badge
  Rx<MessageBadgeModel?> badgeModel = Rx(null);

  Future<void> refreshBadge() async {
    if (UserStore.of.isLogin) {
      try {
        final res = await CommonService.of.getMessageBadge();
        if (res.isSuccess) {
          badgeModel.value = MessageBadgeModel.fromJson(res.data);
        }
      } catch (e) {}
    } else {
      badgeModel.value = null;
    }
  }
}
