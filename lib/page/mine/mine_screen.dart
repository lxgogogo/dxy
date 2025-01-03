import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
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
  final List<String> tabs = ['帖子', '收藏', '评论'];
  late final TabController tabController;

  bool _isMounted = false;
  UserProfile? userProfile;

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
    getUserInfo();
    _isMounted = true;
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshPersonalProfile.eventBusTypeName) {
        getUserInfo();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void getUserInfo() {
    LoginHelper().getUserInfo((data) {
      if (_isMounted) {
        userProfile = data;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/images/setting.png',
                width: 20.px,
                height: 20.px,
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
              margin: EdgeInsets.symmetric(horizontal: 8.px),
              padding: EdgeInsets.all(6.px),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/profile_header.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: userInfoView(),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 12.px),
                decoration: BoxDecoration(
                    color: const Color(0xfff2f9ff),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffb9d0e5).withOpacity(0.64),
                        offset: Offset(0, -1.px),
                        blurRadius: 2.rpx,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: const Color(0xffffffff),
                        offset: Offset(0, 1.px),
                        blurRadius: 2.rpx,
                        spreadRadius: 1.px,
                      )
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      controller: tabController,
                      tabs: tabs.map((e) => Tab(text: e)).toList(),
                      isScrollable: false,
                      labelPadding: EdgeInsets.fromLTRB(6.px, 6.px, 6.px, 0),
                      indicatorPadding: EdgeInsets.only(bottom: 4.px),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: const Color(0xff6198f7),
                          width: 2.px, // 选中线条宽度
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 8.px),
                        borderRadius: BorderRadius.circular(2.px),
                      ),
                      //底部下标颜色
                      enableFeedback: false,
                      overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                        return Colors.transparent;
                      }),
                      dividerHeight: 0,
                      labelStyle: TextStyle(
                        color: const Color(0xff2c2c2c),
                        fontSize: 16.px,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: const Color(0xff666666),
                        fontSize: 16.px,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          tabs.length,
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
      ),
    );
  }

  Widget userInfoView() {
    return GestureDetector(
        onTap: () {
          Get.toNamed(Routes.personal);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.px, 12.px, 0, 12.px),
          child: Row(
            children: <Widget>[
              Container(
                width: 56.px,
                height: 56.px,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.px),
                ),
                child: Stack(children: <Widget>[
                  ClipOval(
                    child: LoginHelper().getUserAvatar(
                      userProfile?.avatar ?? '',
                      56.px,
                      56.px,
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 8.5.px),
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
                                    fontSize: 16.px, fontWeight: FontWeight.bold, color: const Color(0xff2C2C2C)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 8.px,
                              ),
                              Row(children: [
                                GestureDetector(
                                  child: Text('${userProfile?.followedCount.abbreviateNumber ?? '0'} 关注',
                                      style: TextStyle(
                                        color: const Color(0xff2a2a2a),
                                        fontSize: 12.px,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      )),
                                  onTap: () {
                                    Get.toNamed(Routes.following, arguments: true);
                                  },
                                ),
                                SizedBox(
                                  width: 19.px,
                                ),
                                GestureDetector(
                                  child: Text(
                                    '${userProfile?.fansCount.abbreviateNumber ?? '0'} 粉丝',
                                    style: TextStyle(
                                      color: const Color(0xff2a2a2a),
                                      fontSize: 12.px,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.toNamed(Routes.following, arguments: true);
                                  },
                                )
                              ]),
                            ])),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/arrow_right.png',
                            width: 24.px,
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
