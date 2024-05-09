import 'dart:convert';

import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/page/forum/page_publish_posts.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../model/plate.dart';
import '../../utils/constants.dart';

class ForumTabPage extends StatefulWidget {
  const ForumTabPage({super.key});

  @override
  State<ForumTabPage> createState() => _ForumTabPageState();
}

class _ForumTabPageState extends State<ForumTabPage>
    with SingleTickerProviderStateMixin {

  //默认全部板块
  List<TabData> forumParentTabs = [
    TabData(
      index: 0,
      title: Tab(
        child: Text('全部板块'),
      ),
      content: ForumTabChildPage(tabId: 0),
    )
  ];

  @override
  void initState() {
    super.initState();
    getPlateData();
  }

  void getPlateData() {
    NetRequest().getBoardData((data) {
      List<PlateInfo> dataList =
          List<PlateInfo>.from(data.map((plate) => PlateInfo.fromJson(plate)));
      setState(() {
        for (int i = 0; i < dataList.length; i++) {
          PlateInfo plateInfo = dataList[i];
          forumParentTabs.add(TabData(
            index: i + 1,
            title: Tab(
              child: Text(plateInfo.name!),
            ),
            content: ForumTabChildPage(tabId: plateInfo.id!),
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: null,
      body: SafeArea(child: getTabView()),
      backgroundColor: sortBtnBgtColor,
      floatingActionButton: bottomFloatingButton(),
    );
  }

  ///tabView
  Widget getTabView() {
    return Container(
      margin: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
      child: DynamicTabBarWidget(
        onAddTabMoveTo: MoveToTab.idol, //当添加新标签时，指示器将保持在当前0位置标签上。
        dynamicTabs: forumParentTabs,
        isScrollable: true,
        padding: EdgeInsets.only(left: 5.px),
        tabAlignment: TabAlignment.start,
        showBackIcon: false,
        showNextIcon: false,
        labelPadding: EdgeInsets.fromLTRB(0, 0, 20.px, 0),
        indicatorColor: Colors.transparent,
        //底部下标颜色
        enableFeedback: false,
        dividerHeight: 0,
        labelStyle: TextStyle(
            height: 1,
            color: forumAppMainColor,
            fontSize: 17.px,
            fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
            height: 1,
            color: tabTitleUnselectColor,
            fontSize: 17.px,
            fontWeight: FontWeight.w400),
        onTabChanged: (index) {},
        onTabControllerUpdated: (controller) {
        },
      ),
    );
  }

  ///底部FloatingButton
  Widget bottomFloatingButton() {
    return FloatingActionButton(
      child: Image.asset(
        'assets/images/posting_btn.png',
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
