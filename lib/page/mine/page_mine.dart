import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/mine/page_mine_child.dart';
import 'package:holdem/page/mine/page_mine_follow.dart';
import 'package:holdem/page/mine/page_personal.dart';
import 'package:holdem/page/mine/page_settings.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/PostListView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/board_list.dart';
import '../../model/thread_list.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/storage.dart';
import 'login_helper.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  final List<String> tabs = ['帖子', '收藏', '评论'];

  int pageNum = 1;
  int pageSize = 10;

  late UserProfile userProfile = UserProfile();
  var actionEventBus;
  bool _isMounted = false;

  List<BoardBean> boardPostList = [];
  List<CommentBean> commentDataList = [];

  late TabController _tabController =
      TabController(length: 3, vsync: this); // 3 为选项卡数量

  // RefreshController _refreshController1 =
  //     RefreshController(initialRefresh: false);
  // RefreshController _refreshController2 =
  //     RefreshController(initialRefresh: false);
  // RefreshController _refreshController3 =
  //     RefreshController(initialRefresh: false);
  //
  // void _onRefresh() async {
  //   setState(() {
  //     pageNum = 1;
  //   });
  //   // reqListData();
  // }
  //
  // void _onLoading() async {
  //   setState(() {
  //     pageNum++;
  //   });
  //   // reqListData();
  // }

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
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void getUserInfo() {
    LoginHelper().getUserInfo((data) {
      setState(() {
        userProfile = data;
        print('userProfile=======' + userProfile!.nickname!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/setting.png',
              width: 35.px,
              height: 38.px,
            ),
            onPressed: () {
              Get.to(SettingsPage());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_top.png', // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.transparent, // 设置背景颜色为灰色
            child: Column(
              children: [
                SafeArea(
                    child: SizedBox(
                  height: 0.px,
                )),
                userInfoView(),
                _tabBar(),
                Expanded(child: _tabBarView())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
        margin: EdgeInsets.only(top: 23.px),
        padding: EdgeInsets.only(top: 10.px, bottom: 5.px),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 5.px,
            ),
            ...List<Widget>.generate(tabs.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                    _tabController.index = index;
                  });
                },
                child: Container(
                  // margin: EdgeInsets.only(left:41.px,right: 51.px),
                  child: Column(
                    children: [
                      Text(tabs[index],
                          style: TextStyle(
                              color: _currentTabIndex == index
                                  ? Color(0xff008EFF)
                                  : Color(0xff647A9C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.px)),
                      _currentTabIndex == index
                          ? Image.asset('assets/images/tab_sel.png',
                              width: 30.px, height: 6.px)
                          : Container(),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(
              width: 5.px,
            )
          ],
        ));
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        MineChildPage(tabIndex: 0),
        MineChildPage(tabIndex: 1),
        MineChildPage(tabIndex: 2),
      ],
    );
  }

  Widget userInfoView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          width: 16.px,
        ),
        GestureDetector(
            onTap: () {
              Get.to(PersonalPage());
            },
            child: Container(
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
            )),
        Container(
          // height: 63.px,
          margin: EdgeInsets.only(left: 16.px),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 6,
            ),
            Text(
              userProfile != null && userProfile.nickname != null
                  ? userProfile.nickname!
                  : '',
              style: AppTheme.text3B5078Size20,
            ),
            Row(children: [
              GestureDetector(
                child: Row(
                  children: [
                    Text(
                        userProfile != null && userProfile.followedCount != null
                            ? userProfile!.followedCount.toString()
                            : '0',
                        style: AppTheme.text3B5078Size16),
                    Text(' 关注', style: AppTheme.text3B5078Size12),
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
                      userProfile != null && userProfile.fansCount != null
                          ? userProfile!.fansCount.toString()
                          : '0',
                      style: AppTheme.text3B5078Size16),
                  Text(' 粉丝', style: AppTheme.text3B5078Size12)
                ]),
                onTap: () {
                  Get.to(MineFollowPage(isFollowPage: false));
                },
              )
            ]),
          ]),
        ),
        Expanded(
          child: Text(''),
        ),
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
    );
  }
}
