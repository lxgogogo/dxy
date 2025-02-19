import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/personal/personal_screen.dart';
import 'package:holdem/page/mine/widgets/mine_child_view.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';

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
    return BackgroundContainer(
      child: GetBuilder<MineController>(
        init: MineController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Image.asset(
                    'assets/images/setting.png',
                    width: 20.w,
                    height: 20.w,
                  ),
                  onPressed: () {
                    Get.toNamed(Routes.setting);
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  padding: EdgeInsets.all(6.w),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/profile_header.png',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: userInfoView(controller.userProfile),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.w),
                    decoration: BoxDecoration(
                        color: const Color(0xfff2f9ff),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffb9d0e5).withOpacity(0.64),
                            offset: Offset(0, -1.w),
                            blurRadius: 2.rpx,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0xffffffff),
                            offset: Offset(0, 1.w),
                            blurRadius: 2.rpx,
                            spreadRadius: 1.w,
                          )
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TabBar(
                          controller: controller.tabController,
                          tabs: controller.tabs.map((e) => Tab(text: e)).toList(),
                          isScrollable: false,
                          labelPadding: EdgeInsets.fromLTRB(6.w, 6.w, 6.w, 0),
                          indicatorPadding: EdgeInsets.only(bottom: 4.w),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: const Color(0xff6198f7),
                              width: 2.w, // 选中线条宽度
                            ),
                            insets: EdgeInsets.symmetric(horizontal: 8.w),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          //底部下标颜色
                          enableFeedback: false,
                          overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                            return Colors.transparent;
                          }),
                          dividerHeight: 0,
                          labelStyle: TextStyle(
                            color: const Color(0xff2c2c2c),
                            fontSize: 16.w,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: TextStyle(
                            color: const Color(0xff666666),
                            fontSize: 16.w,
                            fontWeight: FontWeight.w400,
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
          );
        },
      ),
    );
  }

  Widget userInfoView(UserProfile? userProfile) {
    return GestureDetector(
        onTap: () {
          Get.toNamed(Routes.personal);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.w, 12.w, 0, 12.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Stack(children: <Widget>[
                  ClipOval(
                    child: LoginHelper().getUserAvatar(
                      userProfile?.avatar ?? '',
                      56.w,
                      56.w,
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 8.5.w),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              Text(
                                userProfile?.nickname ?? '',
                                style: TextStyle(
                                    fontSize: 16.w, fontWeight: FontWeight.bold, color: const Color(0xff2C2C2C)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 8.w,
                              ),
                              Row(children: [
                                GestureDetector(
                                  child: Text('${userProfile?.followedCount.abbreviateNumber ?? '0'} 关注',
                                      style: TextStyle(
                                        color: const Color(0xff2a2a2a),
                                        fontSize: 12.w,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      )),
                                  onTap: () {
                                    Get.toNamed(Routes.following, arguments: true);
                                  },
                                ),
                                SizedBox(
                                  width: 19.w,
                                ),
                                GestureDetector(
                                  child: Text(
                                    '${userProfile?.fansCount.abbreviateNumber ?? '0'} 粉丝',
                                    style: TextStyle(
                                      color: const Color(0xff2a2a2a),
                                      fontSize: 12.w,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.toNamed(Routes.following, arguments: false);
                                  },
                                )
                              ]),
                            ])),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/arrow_right.png',
                            width: 24.w,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.personal);
                          },
                        )
                      ],
                    )),
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
