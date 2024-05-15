import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/page/forum/page_publish_posts.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../model/board_info.dart';
import '../../utils/constants.dart';
import '../../utils/global.dart';
import '../mine/page_login.dart';

class ForumTabPage extends StatefulWidget {
  ForumTabPage({super.key});

  @override
  State<ForumTabPage> createState() => _ForumTabPageState();
}

class _ForumTabPageState extends State<ForumTabPage>
    with SingleTickerProviderStateMixin {
  late int currentBoardId = 0;
  late List<BoardInfo> boardInfoList;

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
    boardInfoList = [];
    getPlateData();
  }

  void getPlateData() {
    NetRequest().getBoardData((data) {
      List<BoardInfo> dataList =
          List<BoardInfo>.from(data.map((plate) => BoardInfo.fromJson(plate)));
      setState(() {
        boardInfoList = dataList;
        for (int i = 0; i < dataList.length; i++) {
          BoardInfo boardInfo = dataList[i];
          forumParentTabs.add(TabData(
            index: i + 1,
            title: Tab(
              child: Text(boardInfo.name!),
            ),
            content: ForumTabChildPage(tabId: boardInfo.id!),
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
        onTabChanged: (index) {
          if (index == 0) {
            currentBoardId = 0;
          } else {
            //默认增加了全部 下标-1
            currentBoardId = boardInfoList[index! - 1].id!;
          }
        },
        onTabControllerUpdated: (controller) {},
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
      onPressed: () {
        if (!Global().hasLogin) {
          Get.to(LoginPage());
          return;
        }
        Get.to(PublishPostsPage(currentBoardId: currentBoardId));
      },
      shape: CircleBorder(),
    );
  }
}
