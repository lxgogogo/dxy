import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/page/mine/page_mine_follow.dart';
import 'package:holdem/page/mine/page_personal.dart';
import 'package:holdem/page/mine/page_settings.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/PostListView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  int _currentTabIndex = 0;
  final List<String> tabs = ['帖子', '收藏', '评论'];

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController1 =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController3 =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    if (_currentTabIndex == 0) {
      _refreshController1.refreshCompleted();
    } else if (_currentTabIndex == 1) {
      _refreshController2.refreshCompleted();
    } else if (_currentTabIndex == 2) {
      _refreshController3.refreshCompleted();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    if (_currentTabIndex == 0) {
      _refreshController1.loadComplete();
    } else if (_currentTabIndex == 1) {
      _refreshController2.loadComplete();
    } else if (_currentTabIndex == 2) {
      _refreshController3.loadComplete();
    }
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
          // Positioned(left: 16, top: 100, child: userInfoView()),
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
                tabView(),
                Expanded(
                    child: Container(color: Colors.white, child: listView()))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userInfoView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          width: 16.px,
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
              child: Image.network(
                'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ]),
        ),
        Container(
          height: 60,
          margin: EdgeInsets.only(left: 16.px),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                '用户昵称',
                style: AppTheme.text3B5078Size20,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(MineFollowPage());
                },
                child: Row(
                  children: [
                    Text('10', style: AppTheme.text3B5078Size16),
                    Text('关注', style: AppTheme.text3B5078Size12),
                    SizedBox(
                      width: 20.px,
                    ),
                    Text('100', style: AppTheme.text3B5078Size16),
                    Text('收藏', style: AppTheme.text3B5078Size12),
                  ],
                ),
              )
            ],
          ),
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

  Widget tabView() {
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

  ///列表数据
  Widget listView() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: getRefreshController(),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => PostListItemView(itemIndex: i),
        // itemExtent: 160.0,
        itemCount: items.length,
      ),
    );
  }

  getRefreshController() {
    if (_currentTabIndex == 0) {
      return _refreshController1;
    } else if (_currentTabIndex == 1) {
      return _refreshController2;
    } else if (_currentTabIndex == 2) {
      return _refreshController3;
    }
  }
}
