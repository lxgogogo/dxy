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

import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            Get.toNamed(Routes.personal);
                          },
                          child: Center(
                            child: ClipOval(
                              child: CachedNetworkImage(
                                width: 88.w,
                                height: 88.w,
                                fit: BoxFit.cover,
                                imageUrl: controller.userProfile?.avatar ?? '',
                                errorWidget: (context, url, error) => Image.asset('assets/images/default_avatar.png'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          controller.userProfile?.nickname ?? '',
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
                                '${controller.userProfile?.followedCount.abbreviateNumber ?? '0'} 关注',
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
                                '${controller.userProfile?.fansCount.abbreviateNumber ?? '0'} 粉丝',
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
                    ),
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
                              indicatorPadding: EdgeInsets.only(bottom: 4.w),
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  color: const Color(0xff557BF6),
                                  width: 2.w, // 选中线条宽度
                                ),
                                insets: EdgeInsets.symmetric(horizontal: 10.w),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              //底部下标颜色
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
