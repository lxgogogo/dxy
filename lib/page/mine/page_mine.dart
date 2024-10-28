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

import '../../model/board_list.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import 'login_helper.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
      if (event.toString() ==
          EventBusAction.refreshPersonalProfile.eventBusTypeName) {
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
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: const Color(0xffE4EEF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
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
      body: Stack(
        children: [
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     'assets/images/home_top.png', // 替换为你的图片路径
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Container(
            color: Colors.transparent, // 设置背景颜色为灰色
            child: Column(
              children: [
                SafeArea(
                    child: SizedBox(
                  height: 0.px,
                )),
                Center(
                  child: Container(
                    width: 343.px,
                    height: 93.px,
                    padding: EdgeInsets.only(left: 10.px, right: 12.px),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        // color: Colors.red
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/profile_header.png'),
                            fit: BoxFit.cover)),
                    child: userInfoView(),
                  ),
                ),

                // _tabBar2(),
                Expanded(child: _tabBarView())
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _tabBar() {
  //   return Container(
  //       margin: EdgeInsets.only(top: 23.px),
  //       // padding: EdgeInsets.only(top: 15.px, bottom: 15.px),
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(12),
  //           topRight: Radius.circular(12),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           SizedBox(
  //             width: 5.px,
  //           ),
  //           ...List<Widget>.generate(tabs.length, (index) {
  //             return GestureDetector(
  //               onTap: () {
  //                 _switchTab(index);
  //               },
  //               child: Container(
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: 40.px, vertical: 15.px),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                 ),
  //                 // margin: EdgeInsets.only(left:41.px,right: 51.px),
  //                 child: Column(
  //                   children: [
  //                     Text(tabs[index],
  //                         style: TextStyle(
  //                             color: _currentTabIndex == index
  //                                 ? Color(0xff008EFF)
  //                                 : Color(0xff647A9C),
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16.px)),
  //                     _currentTabIndex == index
  //                         ? Image.asset('assets/images/tab_sel.png',
  //                             width: 30.px, height: 6.px)
  //                         : Container(),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }),
  //           SizedBox(
  //             width: 5.px,
  //           )
  //         ],
  //       ));
  // }
  //
  // _switchTab(int index) {
  //   if (_isMounted) {
  //     setState(() {
  //       _currentTabIndex = index;
  //       _tabController.index = index;
  //     });
  //   }
  // }

  Widget _tabBarView() {
    // return Builder(
    //   builder: (BuildContext context) {
    //     _tabController.addListener(() {
    //       int currentIndex = _tabController.index;
    //       print('Current tab index:========== $currentIndex');
    //       _switchTab(currentIndex);
    //     });
    //     return TabBarView(
    //       controller: _tabController,
    //       children: <Widget>[
    //         MineChildPage(tabIndex: 0),
    //         MineChildPage(tabIndex: 1),
    //         MineChildPage(tabIndex: 2),
    //       ],
    //     );
    //   },
    // );
    return Container(
        margin: EdgeInsets.only(top: 23.px),
        // padding: EdgeInsets.only(top: 15.px, bottom: 15.px),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6FBFF),
              Color(0xFFE8F3FF),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: DynamicTabBarWidget(
          dynamicTabs: parentTabs,
          isScrollable: false,
          showBackIcon: false,
          showNextIcon: false,
          labelPadding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
          indicatorPadding: const EdgeInsets.only(bottom: 5),
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: const Color(0xff008EFF), // 选中线条颜色
                width: 2.px, // 选中线条宽度
              ),
              insets: EdgeInsets.symmetric(horizontal: 4.px), // 选中线条左右间距
              borderRadius: BorderRadius.circular(1.px)),
          //底部下标颜色
          enableFeedback: false,
          dividerHeight: 0,
          labelStyle: TextStyle(
              height: 1,
              color: Color(0xff2c2c2c),
              fontSize: 16.px,
              fontWeight: FontWeight.w400),
          unselectedLabelStyle: TextStyle(
              height: 1,
              color: tabTitleUnselectColor,
              fontSize: 15.px,
              fontWeight: FontWeight.w400),
          onTabChanged: (index) {},
          onTabControllerUpdated: (TabController) {},
        ));
  }

  Widget userInfoView() {
    return GestureDetector(
        onTap: () {
          Get.to(PersonalPage());
        },
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 5.px,
            ),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Stack(children: <Widget>[
                ClipOval(
                    child: LoginHelper().getUserAvatar(
                        userProfile.avatar != null ? userProfile.avatar! : '',
                        60,
                        60)),
              ]),
            ),
            Expanded(
              child: Container(
                  // height: 63.px,
                  margin: EdgeInsets.only(left: 16.px),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Container(
                                child: Text(
                              userProfile != null &&
                                      userProfile.nickname != null
                                  ? userProfile.nickname!
                                  : '',
                              style: TextStyle(
                                  fontSize: 16.px,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2C2C2C)),
                              overflow: TextOverflow.ellipsis,
                            )),
                            SizedBox(
                              height: 6.px,
                            ),
                            Row(children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Text(
                                        userProfile != null &&
                                                userProfile.followedCount !=
                                                    null
                                            ? userProfile!.followedCount
                                                .toString()
                                            : '0',
                                        style: TextStyle(
                                            color: const Color(0xff2a2a2a),
                                            fontSize: 13.px,
                                            fontWeight: FontWeight.bold)),
                                    Text(' 关注',
                                        style: TextStyle(
                                            color: const Color(0xff2a2a2a),
                                            fontSize: 13.px,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                onTap: () {
                                  Get.to(MineFollowPage(isFollowPage: true));
                                },
                              ),
                              SizedBox(
                                width: 20.px,
                              ),
                              GestureDetector(
                                child: Row(children: [
                                  Text(
                                      userProfile != null &&
                                              userProfile.fansCount != null
                                          ? userProfile!.fansCount.toString()
                                          : '0',
                                      style: TextStyle(
                                          color: const Color(0xff2a2a2a),
                                          fontSize: 13.px,
                                          fontWeight: FontWeight.bold)),
                                  Text(' 粉丝', style: TextStyle(
                                      color: const Color(0xff2a2a2a),
                                      fontSize: 13.px,
                                      fontWeight: FontWeight.bold))
                                ]),
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
                          height: 24.px,
                        ),
                        onPressed: () {
                          Get.to(PersonalPage());
                        },
                      )
                    ],
                  )),
            ),
          ],
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
