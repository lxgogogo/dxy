import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/app_version.dart';
import 'package:holdem/page/feed_list/feed_list_screen.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/message/message_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/dialog_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/event_bus_util.dart';
import '../mine/mine_screen.dart';

part 'main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return BackgroundContainer(
      child: GetBuilder<MainController>(
        init: MainController(),
        builder: (controller) {
          return Scaffold(
            body: [
              const HomeScreen(),
              const FeedListScreen(),
              const MessagePage(),
              const MineScreen(),
            ][controller.currentIndex],
            backgroundColor: Colors.transparent,
            bottomNavigationBar: Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.only(top: 12.w),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1e0000).withOpacity(0.12),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: controller.currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  selectedItemColor: const Color(0xff008EFF),
                  unselectedItemColor: const Color(0xff9CACC9),
                  showSelectedLabels: true,
                  // 取消显示选中项的标签
                  showUnselectedLabels: true,
                  // 取消显示未选中项的标签
                  useLegacyColorScheme: false,
                  onTap: controller.onTabBarItem,
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        controller.currentIndex == 0
                            ? 'assets/images/tab_index_sel.png'
                            : 'assets/images/tab_index.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '首页',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        controller.currentIndex == 1
                            ? 'assets/images/tab_forum_sel.png'
                            : 'assets/images/tab_forum.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '论坛',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        controller.currentIndex == 2
                            ? 'assets/images/tab_message_sel.png'
                            : 'assets/images/tab_message.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '消息',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        controller.currentIndex == 3 ? 'assets/images/tab_me_sel.png' : 'assets/images/tab_me.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '我的',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
