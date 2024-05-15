import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:holdem/page/message/page_message_tab_child.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  List<TabData> parentTabs = [];

  final List<Tab> myTabs = const <Tab>[
    Tab(text: '@我的'),
    Tab(text: '评论我的'),
    Tab(text: '赞我的'),
    Tab(text: '收藏'),
  ];

  final List<String> types = ['at', 'comment', 'like', 'favorate'];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < myTabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Text(myTabs[i].text.toString()),
        ),
        content: MessageTabChildPage(type: types[i]),
      ));
    }
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
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
        // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
        appBar: AppBar(
          // backgroundColor: Colors.transparent, // 设置导航条背景透明
          // elevation: 0, // 去除导航条的阴影
          title: Text('消息'),
          
        ),
        body: getTabView(),);
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}