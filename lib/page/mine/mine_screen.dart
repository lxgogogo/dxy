import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/mine/widgets/mine_child_view.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';

import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../widget/custom_underline_tab_indicator.dart';
import 'login_helper.dart';

part 'mine_controller.dart';

class MineScreen extends StatefulWidget {
  const MineScreen({super.key});

  @override
  State<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends State<MineScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<MineController>(
      init: MineController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Container(
                height: 268.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.mineHeaderBg.provider(),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Obx(() {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.personal);
                            },
                            child: Center(
                              child: SizedBox(
                                width: 88.w,
                                height: 88.w,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: UserStore.of.user?.avatar ?? '',
                                    cacheKey: UserStore.of.user?.avatar ?? '',
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.white,
                                    )),
                                    errorWidget: (_, __, ___) => Assets.images.imageLoadingDef.image(
                                      fit: BoxFit.fill,
                                    ),
                                    fadeOutDuration: Duration.zero,
                                    fadeInDuration: Duration.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.w),
                          Text(
                            UserStore.of.user?.nickname ?? '',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff333333),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.following, arguments: true);
                                },
                                child: Text(
                                  '关注 ${UserStore.of.user?.followedCount.abbreviateNumber ?? '0'}',
                                  style: TextStyle(
                                    color: const Color(0xff6B6D70),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 24.w),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.following, arguments: false);
                                },
                                child: Text(
                                  '粉丝 ${UserStore.of.user?.fansCount.abbreviateNumber ?? '0'}',
                                  style: TextStyle(
                                    color: const Color(0xff6B6D70),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24.w + 268.w - 239.w),
                        ],
                      );
                    }),
                    Positioned(
                      top: ScreenUtil().statusBarHeight + 4.w,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.setting);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: SvgPicture.asset(
                            Assets.svg.iconSetting,
                            width: 24.w,
                            height: 24.w,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 239.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                            child: TabBar(
                              controller: controller.tabController,
                              tabs: controller.tabs.map((e) => Tab(text: e)).toList(),
                              isScrollable: false,
                              indicator: RoundUnderlineTabIndicator(
                                borderSide: BorderSide(width: 2.w, color: const Color(0xff4260FF)),
                                wantToWith: 12.w,
                              ),
                              enableFeedback: false,
                              overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                                return Colors.transparent;
                              }),
                              dividerHeight: 0,
                              labelStyle: TextStyle(
                                color: const Color(0xff333333),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                color: const Color(0xff333333),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: controller.tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                controller.tabs.length,
                                (index) => MineChildView(tabIndex: index),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
