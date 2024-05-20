import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_index_tab_child.dart';
import 'package:holdem/page/index/page_search.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with AutomaticKeepAliveClientMixin {
  int _currentTabIndex = 0;
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];
  final List<String> types = ['news', 'video', 'book', 'course'];
  List<TabData> parentTabs = [];

  List<ArticleBean> articles = [];

  @override
  void initState() {
    super.initState();

    // String dateString = '2024-05-06T17:12:03+08:00';
    // DateTime date = DateTime.parse(dateString).toLocal();

    for (int i = 0; i < tabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Text(tabs[i]),
        ),
        content: IndexTabChildPage(type: types[i]),
      ));
    }
  }

  void getVideos() {
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'categoryAlias': 'video' //'article'
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data['list'].map((article) => ArticleBean.fromJson(article)));
      setState(() {
        articles = dataList;
      });
    });
  }

  void getArticles() {
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'categoryAlias': 'book' //'article'
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data['list'].map((article) => ArticleBean.fromJson(article)));
      setState(() {
        articles = dataList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        // elevation: 0, // 去除导航条的阴影
        title: Text('首页'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/navi_search.png',
              width: 35.px,
              height: 38.px,
            ),
            onPressed: () {
              // 登录按钮点击事件
              Get.to(SearchPage());
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
                Expanded(child: getTabView())
              ],
            ),
          ),
        ],
      ),
      // body: getTabView(),
    );
  }

  Widget getTabView() {
    return DynamicTabBarWidget(
      dynamicTabs: parentTabs,
      isScrollable: false,
      showBackIcon: false,
      showNextIcon: false,
      labelPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      indicatorColor: Colors.transparent,
      //底部下标颜色
      enableFeedback: false,
      dividerHeight: 0,
      labelStyle: TextStyle(
          height: 1,
          color: forumAppMainColor,
          fontSize: 16.px,
          fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
          height: 1,
          color: tabTitleUnselectColor,
          fontSize: 16.px,
          fontWeight: FontWeight.w400),
      onTabChanged: (index) {},
      onTabControllerUpdated: (TabController) {},
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

/*
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        title: Row(
          children: [
            ...List<Widget>.generate(tabs.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                    if (index==1){
                      getVideos();
                    }
                    if (index==2){
                      getArticles();
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 23.px),
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
            })
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/navi_search.png',
              width: 35.px,
              height: 38.px,
            ),
            onPressed: () {
              // 登录按钮点击事件
              Get.to(SearchPage());
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
                Expanded(child: Container())
              ],
            ),
          ),
        ],
      ),
    );
  }
*/
}
