import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:oktoast/oktoast.dart';

class Global {
  static final Global _instance = Global._internal();
  RouteObserver<ModalRoute>? routeObserver;
  String token = '';
  String deviceId = '';
  int timeSeconds = 0; //与服务器的时间戳差
  bool hasLogin = false; //是否登录
  bool showDialog = false; //是否存在弹窗，防止同一时间多次弹窗的情况

  bool showLogin = false; //是否显示登录页面
  bool allowNotification = false; //是否允许推送


  dynamic mainPage;
  dynamic homePage;

  factory Global() {
    return _instance;
  }

  Global._internal() {
    init();
  }

  void init() {}

  void checkLogin(VoidCallback callback) async {
    if(!hasLogin) {
      showToast('请先登录',duration: const Duration(seconds: 2));
      Get.to(LoginScreen());
      return;
    }
    callback.call();
  }
}
