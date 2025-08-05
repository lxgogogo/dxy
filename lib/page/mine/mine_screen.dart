import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/page/mine/widgets/mine_child_view.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';

import '../../utils/track_utils.dart';
import '../../widget/custom_underline_tab_indicator.dart';
import 'widgets/mine_collect_view.dart';
import 'widgets/mine_tabbar_widget.dart';

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
              Image.asset(
                Assets.images.mineHeaderBg.path,
                width: 1.sw,
                fit: BoxFit.fitWidth,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => FocusDetector(
                        onFocusGained: controller.onFocusGained,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 56.w,
                              margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.equityCenter);
                                            },
                                            child: Container(
                                              width: 84.w,
                                              height: 24.w,
                                              margin: EdgeInsets.only(left: 16.w),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(12.w)),
                                                  border: Border.all(width: 1.w, color: AppTheme.color_557BF6)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Assets.images.icMinePowerCenter.path,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    '权益中心',
                                                    style: TextStyle(fontSize: 12.sp, color: AppTheme.color_557BF6),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.pointsConversion);
                                            },
                                            child: Container(
                                              width: 84.w,
                                              height: 24.w,
                                              margin: EdgeInsets.only(left: 10.w),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(12.w)),
                                                  border: Border.all(width: 1.w, color: AppTheme.color_557BF6)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Assets.images.iconPoints.path,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    '积分兑换',
                                                    style: TextStyle(fontSize: 12.sp, color: AppTheme.color_557BF6),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.scan);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 8.w, left: 16.w, top: 6.w, bottom: 6.w),
                                              child: SvgPicture.asset(
                                                Assets.svg.iconScan,
                                                width: 24.w,
                                                height: 24.w,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.setting);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 16.w, left: 8.w, top: 6.w, bottom: 6.w),
                                              child: SvgPicture.asset(
                                                Assets.svg.iconSetting,
                                                width: 24.w,
                                                height: 24.w,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        Get.toNamed(Routes.personal);
                                      },
                                      child: SizedBox(
                                        width: 48.w,
                                        height: 48.w,
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
                                      )),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxWidth: 1.sw - 32.w - 48.w - 60.w - 24.w),
                                            child: Text(
                                              UserStore.of.user?.nickname ?? '',
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.color_333333,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: 84.w,
                                            height: 22.w,
                                            margin: EdgeInsets.only(left: 6.w),
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(Assets.images.iconMineSignBg.path),
                                                    fit: BoxFit.fill)),
                                            child: AutoSizeText(
                                              UserStore.of.user?.userLevel?.name ?? '',
                                              maxLines: 1,
                                              minFontSize: 8,
                                              style: TextStyle(
                                                  fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5.w),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.following, arguments: true);
                                              TrackUtils.trackEvent(userLogType: '113004');
                                            },
                                            child: Text(
                                              '关注 ${UserStore.of.user?.followedCount.abbreviateNumber ?? '0'}',
                                              style: TextStyle(
                                                color: AppTheme.color_666666,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.following, arguments: false);
                                              TrackUtils.trackEvent(userLogType: '113005');
                                            },
                                            child: Text(
                                              '粉丝 ${UserStore.of.user?.fansCount.abbreviateNumber ?? '0'}',
                                              style: TextStyle(
                                                color: AppTheme.color_666666,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                      child: DefaultTabController(
                          length: 3,
                          child: Container(
                            margin: EdgeInsets.only(top: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                                  child: StableTabBar(
                                      tabController: controller.tabController,
                                      onTap: (index) {
                                        TrackUtils.trackEvent(
                                          userLogType: index == 0
                                              ? '113001'
                                              : index == 1
                                                  ? '113002'
                                                  : '113003',
                                        );
                                      }),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: controller.tabController,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: List.generate(controller.tabs.length, (index) {
                                      if (index == 1) {
                                        return const MineCollectView();
                                      } else {
                                        return MineChildView(tabIndex: index);
                                      }
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          )))
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
