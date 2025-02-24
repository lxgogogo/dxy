import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
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
    return GetBuilder<MainController>(
      init: MainController(),
      builder: (controller) {
        return Scaffold(
          body: [
            const HomeScreen(),
            const FeedListScreen(),
            const MessagePage(),
            const MineScreen(),
          ][controller.currentIndex],
          backgroundColor: Colors.white,
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                padding: EdgeInsets.only(top: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: controller.currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  selectedFontSize: 10.sp,
                  unselectedFontSize: 10.sp,
                  selectedItemColor: '#557BF6'.hexColor,
                  unselectedItemColor: '#333333'.hexColor,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  useLegacyColorScheme: false,
                  onTap: controller.onTabBarItem,
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        controller.currentIndex == 0 ? Assets.svg.navIconHomeAct : Assets.svg.navIconHomeAct,
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '首页',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        controller.currentIndex == 0 ? Assets.svg.navIconFeed : Assets.svg.navIconFeedAct,
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '论坛',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        controller.currentIndex == 0 ? Assets.svg.navIconMessage : Assets.svg.navIconMessageAct,
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '消息',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        controller.currentIndex == 0 ? Assets.svg.navIconMine : Assets.svg.navIconMineAct,
                        width: 20.w,
                        height: 20.w,
                      ),
                      label: '我的',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
