import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/page/mine/page_login.dart';

import '../../model/user.dart';
import '../../utils/net_request.dart';
import '../../utils/storage.dart';

typedef LoginSuccess = void Function(dynamic data);

class LoginHelper {
   getUserInfo(LoginSuccess loginSuccess) {
    String? token = StorageUtil().prefs!.getString('token');
    print('token=======' + token!);
    String? account = StorageUtil().prefs!.getString('userAccount');
    String? password = StorageUtil().prefs!.getString('userPw');

    NetRequest().getUserInfo(account ?? '', password ?? '', (data) {
      UserProfile user = UserProfile.fromJson(data);
      loginSuccess(user);
    }, (errorMsg) {
      //重新登录
      Get.to(LoginPage());
    });
  }

  //获取图像
  Widget getUserAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl.isNotEmpty ? avatarUrl : '',
      placeholder: (context, url) =>
          Image.asset('assets/images/default_avatar.png'),
      errorWidget: (context, url, error) =>
          Image.asset('assets/images/default_avatar.png'),
    );
  }
}