import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/page/forum/page_publish_posts.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../utils/constants.dart';

class ForumTabPage extends StatefulWidget {
  const ForumTabPage({super.key});

  @override
  State<ForumTabPage> createState() => _ForumTabPageState();
}

class _ForumTabPageState extends State<ForumTabPage> with SingleTickerProviderStateMixin{
  List<TabData> forumParentTabs = [];
  // List<String> tabTitles = ['全部板块', '交流大厅', '咪牌技巧', '千王之王', '赌王争霸'];

  final List<Tab> myTabs = <Tab>[
    Tab(text: '全部板块'),
    Tab(text: '交流大厅'),
    Tab(text: '咪牌技巧'),
    Tab(text: '千王之王'),
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < myTabs.length; i++) {
      forumParentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Text(myTabs[i].text.toString()),
        ),
        content: ForumTabChildPage(tabId: i),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: getTabView()),
      backgroundColor: sortBtnBgtColor,
      floatingActionButton: bottomFloatingButton(),
    );
  }

  List<Widget> createPages(List tabList) {
    List<Widget> desList = [];
    for (int i = 0; i < tabList.length; i++) {
      desList.add(ForumTabChildPage(
        tabId: i,
      ));
    }
    return desList;
  }

  ///tabView
  Widget getTabView() {
    return DynamicTabBarWidget(
      dynamicTabs: forumParentTabs,
      isScrollable: false,
      showBackIcon: false,
      showNextIcon: false,
      labelPadding: EdgeInsets.fromLTRB(6, 0, 6, 0),
      indicatorColor: Colors.transparent,
      //底部下标颜色
      enableFeedback: false,
      dividerHeight: 0,
      labelStyle: TextStyle(
          height: 1,
          color: forumAppMainColor,
          fontSize: 18.px,
          fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
          height: 1,
          color: tabTitleUnselectColor,
          fontSize: 18.px,
          fontWeight: FontWeight.w400),
      onTabChanged: (index) {},
      onTabControllerUpdated: (TabController) {},
    );
  }

  ///底部FloatingButton
  Widget bottomFloatingButton() {
    return FloatingActionButton(
      child: Image.asset('assets/images/posting_btn.png',
        width: 100.px,
        height: 106.px,
        fit: BoxFit.fill,
    ),
      backgroundColor: Colors.transparent,
      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [Icon(Icons.add), Text('发帖')],
      // ),
      onPressed: () {
        Get.to(PublishPostsPage());
      },
      shape: CircleBorder(),
    );
  }
}
