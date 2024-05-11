import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/mine/page_login.dart';
import 'package:holdem/page/mine/page_register_account.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/view/forum/ToastUtils.dart';

import '../../utils/app_theme.dart';
import '../../utils/global.dart';
import '../../utils/size_fit.dart';
import '../../utils/storage.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppTheme.color_F3F3F3,
        title: const Text(
          '设置',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: AppTheme.color_F3F3F3,
    );
  }

  Widget contentView() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(16.px, 0, 16.px, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    Get.to(RegisterAccountPage(type: RegisterAccountPage.PageType_ModifyPassword,));
                  },
                  child: const ListTile(
                    leading: ImageIcon(
                      AssetImage('assets/images/password.png'),
                      size: 22,
                    ),
                    title: Text(
                      '修改密码',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: ImageIcon(
                      AssetImage('assets/images/item_arrow.png'),
                      size: 22,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                  )),
              Container(
                  color: AppTheme.color_1A000000,
                  margin: EdgeInsets.only(left: 60.px),
                  width: MediaQuery.of(context).size.width,
                  height: 0.5.px),
              GestureDetector(
                  onTap: () {
                    ToastUtils.showToast("关于我们");
                  },
                  child: const ListTile(
                    leading: ImageIcon(
                      AssetImage('assets/images/about_us.png'),
                      size: 22,
                    ),
                    title: Text(
                      '关于我们',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: ImageIcon(
                      AssetImage('assets/images/item_arrow.png'),
                      size: 22,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                  )),
              Container(
                  color: AppTheme.color_1A000000,
                  margin: EdgeInsets.only(left: 60.px),
                  width: MediaQuery.of(context).size.width,
                  height: 0.5.px),
              GestureDetector(
                  onTap: () {
                    ToastUtils.showToast("检测新版本");
                  },
                  child: const ListTile(
                    leading: ImageIcon(
                      AssetImage('assets/images/version_update.png'),
                      size: 22,
                    ),
                    title: Text(
                      '检测新版本',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: ImageIcon(
                      AssetImage('assets/images/item_arrow.png'),
                      size: 22,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                  )),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(16.px, 10.px, 16.px, 0),
            decoration: BoxDecoration(
              color: Colors.white, // 设置白色背景色
              borderRadius: BorderRadius.circular(10), // 添加圆角
            ),
            child: GestureDetector(
              onTap: () {
                logout();
              },
              child: const ListTile(
                leading: ImageIcon(
                  AssetImage('assets/images/logout.png'),
                  size: 22,
                ),
                title: Text(
                  '退出登录',
                  style: AppTheme.text333333Size15,
                ),
                // 中间文本
                trailing: ImageIcon(
                  AssetImage('assets/images/item_arrow.png'),
                  size: 22,
                ),
                contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
              ),
            )),
      ],
    );
  }

  void logout() {
    NetRequest().logout((data) {
      LoginHelper().clearGlobalUserInfo();
      //回到首页
      Navigator.of(context).pop();
      //通知首页tab回到主页
    });
  }
}
