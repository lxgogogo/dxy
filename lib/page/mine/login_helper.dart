import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/page/mine/page_login.dart';

import '../../model/user.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/global.dart';
import '../../utils/net_request.dart';
import '../../utils/storage.dart';
import '../../view/forum/ToastUtils.dart';

typedef LoginSuccess = void Function(dynamic data);
typedef GetUserInfoSuccess = void Function(dynamic data);

class LoginHelper {
  //登录
  userLogin(String account, String password, LoginSuccess loginSuccessCallBack) {
    NetRequest().userLogin(account, password, (data) {
      UserProfile userProfile = UserProfile.fromJson(data['user']);
      ToastUtils.showToast('登录成功');
      Global().hasLogin = true;
      Global().token = data['token'];
      StorageUtil().setBool('hasLogin', true);
      StorageUtil().prefs!.setString('token', data['token']);
      StorageUtil().prefs!.setString('ownerId', userProfile.id!.toString());
      //保存账号密码，获取本人信息接口需要
      StorageUtil().prefs!.setString('userAccount', account);
      StorageUtil().prefs!.setString('userPw', password);

      //通知个人信息页面刷新
      EventBusManager.eventBus
          .fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);

      loginSuccessCallBack(data);
    });
  }

  getUserInfo(GetUserInfoSuccess getSuccessCallback) {
    String? token = StorageUtil().prefs!.getString('token');
    print('token=======' + token!);
    String? account = StorageUtil().prefs!.getString('userAccount');
    String? password = StorageUtil().prefs!.getString('userPw');

    NetRequest().getUserInfo(account ?? '', password ?? '', (data) {
      UserProfile user = UserProfile.fromJson(data);
      getSuccessCallback(user);
    }, (errorMsg) {

    });
  }

  //获取图像
  Widget getUserAvatar(String avatarUrl, double width, double height) {
    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: avatarUrl.isNotEmpty ? avatarUrl : '',
      placeholder: (context, url) =>
          Image.asset('assets/images/default_avatar.png'),
      errorWidget: (context, url, error) =>
          Image.asset('assets/images/default_avatar.png'),
    );
  }

  ///清空本地用户相关信息，需要重新登录
  clearGlobalUserInfo() {
    //清除本地所有用户信息
    Global().hasLogin = false;
    Global().token = '';
    StorageUtil().setBool('hasLogin', false);
    StorageUtil().prefs!.setString('ownerId', '');
    StorageUtil().prefs!.setString('token', '');
    StorageUtil().prefs!.setString('userAccount', '');
    StorageUtil().prefs!.setString('userPw', '');
  }
}
