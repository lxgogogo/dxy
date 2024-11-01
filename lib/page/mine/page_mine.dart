import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/mine/page_mine_child.dart';
import 'package:holdem/page/mine/page_mine_follow.dart';
import 'package:holdem/page/mine/page_personal.dart';
import 'package:holdem/page/mine/page_settings.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';

import '../../model/board_list.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import 'login_helper.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  final List<String> tabs = ['帖子', '收藏', '评论'];

  int pageNum = 1;
  int pageSize = 10;

  late UserProfile userProfile = UserProfile();
  var actionEventBus;
  bool _isMounted = false;

  List<BoardBean> boardPostList = [];
  List<CommentBean> commentDataList = [];
  List<TabData> parentTabs = [];

  // late TabController _tabController =
  //     TabController(length: 3, vsync: this); // 3 为选项卡数量

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    // reqListData();
    _isMounted = true;
    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshPersonalProfile.eventBusTypeName) {
        getUserInfo();
      }
    });

    for (int i = 0; i < tabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Text(tabs[i]),
        ),
        content: MineChildPage(tabIndex: i),
      ));
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void getUserInfo() {
    LoginHelper().getUserInfo((data) {
      if (_isMounted) {
        setState(() {
          userProfile = data;
          print('userProfile=======' + userProfile!.nickname!);
        });
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
                Get.to(SettingsPage());
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 93.px,
              padding: EdgeInsets.all(6.px),
              margin: EdgeInsets.symmetric(horizontal: 8.px),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/profile_header.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: userInfoView(),
            ),
            Expanded(child: _tabBarView())
          ],
        ),
      ),
    );
  }

  Widget _tabBarView() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.px).copyWith(top: 12.px),
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
          ]
        ),
        child: DynamicTabBarWidget(
          dynamicTabs: parentTabs,
          isScrollable: false,
          showBackIcon: false,
          showNextIcon: false,
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
          onTabChanged: (index) {},
          onTabControllerUpdated: (TabController) {},
        ));
  }

  Widget userInfoView() {
    return GestureDetector(
        onTap: () {
          Get.to(PersonalPage());
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
                      userProfile.avatar != null ? userProfile.avatar! : '',
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
                                userProfile.nickname ?? '',
                                style: TextStyle(
                                    fontSize: 16.px, fontWeight: FontWeight.bold, color: const Color(0xff2C2C2C)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 8.px,
                              ),
                              Row(children: [
                                GestureDetector(
                                  child: Text('${userProfile.followedCount ?? 0} 关注',
                                      style: TextStyle(
                                        color: const Color(0xff2a2a2a),
                                        fontSize: 12.px,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      )),
                                  onTap: () {
                                    Get.to(MineFollowPage(isFollowPage: true));
                                  },
                                ),
                                SizedBox(
                                  width: 19.px,
                                ),
                                GestureDetector(
                                  child: Text(
                                    '${userProfile.fansCount ?? 0} 粉丝',
                                    style: TextStyle(
                                      color: const Color(0xff2a2a2a),
                                      fontSize: 12.px,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.to(MineFollowPage(isFollowPage: false));
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
                            Get.to(PersonalPage());
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
