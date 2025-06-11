import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/message/message_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/utils/toast_utils.dart';

import '../model/message_badge_model.dart';
import '../model/res_base_model.dart';
import '../services/index.dart';
import '../utils/event_bus_util.dart';
import '../utils/net_request.dart';

class UserStore extends GetxController {
  static UserStore get of => Get.find();

  String get localUserStr => StorageService.of.getLocalUserStr();

  final _user = Rx<UserProfile?>(null);

  UserProfile? get user => _user.value ?? UserProfile.fromRawJson(localUserStr.isEmpty ? '{}' : localUserStr);

  bool get hasCourseGroup => user?.courseGroupId != null;

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

  Future<void> refreshLocalBadge(int count, {required MessageType messageType}) async {
    final total = badgeModel.value?.total ?? 0;
    switch (messageType) {
      case MessageType.at:
        final at = badgeModel.value?.at ?? 0;
        if (at - count >= 0) {
          badgeModel.value = badgeModel.value?.copyWith(
            total: total - count,
            at: at - count,
          );
        }
        break;
      case MessageType.comment:
        final comment = badgeModel.value?.comment ?? 0;
        if (comment - count >= 0) {
          badgeModel.value = badgeModel.value?.copyWith(
            total: total - count,
            comment: comment - count,
          );
        }
        break;
      case MessageType.like:
        final like = badgeModel.value?.like ?? 0;
        if (like - count >= 0) {
          badgeModel.value = badgeModel.value?.copyWith(
            total: total - count,
            like: like - count,
          );
        }
        break;
      case MessageType.favorite:
        final favorite = badgeModel.value?.favorite ?? 0;
        if (favorite - count >= 0) {
          badgeModel.value = badgeModel.value?.copyWith(
            total: total - count,
            favorite: favorite - count,
          );
        }
        break;
    }
  }

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

  void loginSuccess(ResBaseModel res) {
    StorageService.of.putToken(res.data['token']);
    FirebaseService.of.initNotifications();
    final userProfile = UserProfile.fromJson(res.data['user']);
    UserStore.of.putUserInfo(userProfile);
    UserStore.of.getUserInfo();
    EventBusUtil.of.fire(EventLoginSuccess());
  }
}
