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
import 'package:holdem/widget/dialog_common.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/message_badge_model.dart';
import '../../utils/debounce_throttle_util.dart';
import '../../utils/event_bus_util.dart';
import '../../utils/track_utils.dart';
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
          body: Stack(
            children: [
              PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const HomeScreen().keepAlive,
                  const FeedListScreen().keepAlive,
                  const MessagePage().keepAlive,
                  const MineScreen().keepAlive,
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                    child: Container(
                      padding: EdgeInsets.only(top: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: BottomNavigationBar(
                        currentIndex: controller.tabIndex,
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
                          _buildBarItem(
                            icon: controller.tabIndex == 0 ? Assets.svg.navIconHomeAct : Assets.svg.navIconHome,
                            label: '首页',
                          ),
                          _buildBarItem(
                            icon: controller.tabIndex == 1 ? Assets.svg.navIconFeedAct : Assets.svg.navIconFeed,
                            label: '论坛',
                          ),
                          _buildBarItem(
                            icon: controller.tabIndex == 2 ? Assets.svg.navIconMessageAct : Assets.svg.navIconMessage,
                            label: '消息',
                            badge: Obx(() {
                              final badgeCount = UserStore.of.badgeModel.value?.total ?? 0;
                              if (badgeCount > 0) {
                                return Positioned(
                                  top: -7.5.w,
                                  right: -7.5.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        Assets.svg.badge,
                                        width: 15.w,
                                        height: 15.w,
                                      ),
                                      Text(
                                        '${badgeCount > 99 ? 99 : badgeCount}',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox();
                            }),
                          ),
                          _buildBarItem(
                            icon: controller.tabIndex == 3 ? Assets.svg.navIconMineAct : Assets.svg.navIconMine,
                            label: '我的',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  BottomNavigationBarItem _buildBarItem({
    required String icon,
    required String label,
    Widget? badge,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            icon,
            width: 20.w,
            height: 20.w,
          ),
          if (badge != null) badge,
        ],
      ),
      label: label,
    );
  }
}
