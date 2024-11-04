import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:holdem/page/message/page_message_tab_child.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with AutomaticKeepAliveClientMixin {
  List<TabData> parentTabs = [];
  int selIndex = 0;

  final List<Tab> myTabs = const <Tab>[
    Tab(text: '@我的'),
    Tab(text: '评论我的'),
    Tab(text: '赞我的'),
    Tab(text: '收藏'),
  ];
  final List<String> tabs = ['@我的', '评论我的', '赞我的', '收藏'];
  final List<String> types = ['at', 'comment', 'like', 'favorite'];
  final _pageKey = GlobalKey<MessageTabChildPageState>();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < myTabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Container(
            // color: Colors.red,
            child: Text(myTabs[i].text.toString()),
          ),
          // child: Text(myTabs[i].text.toString()),
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
      onTabChanged: (index) {
        setState(() {
          selIndex = index!;
        });
      },
      onTabControllerUpdated: (TabController) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 设置导航条背景透明
          // elevation: 0, // 去除导航条的阴影
          title: Text('消息'),
        ),
        backgroundColor: Colors.transparent,
        // body: getTabView(),
        body: detail(),
      ),
    );
  }

  Widget detail() {
    return Column(children: [
      Row(children: [
        SizedBox(
          width: 18.px,
        ),
        ...List.generate(tabs.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selIndex = index;
              });
              _pageKey.currentState?.refreshData(types[selIndex]);
            },
            child: Container(
              height: 30.px,
              margin: EdgeInsets.only(right: 10.px),
              padding: EdgeInsets.symmetric(horizontal: 15.px),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.px),
                  boxShadow: [
                    BoxShadow(
                      color: selIndex == index
                          ? const Color(0xFFC8D4EE)
                          : const Color(0xFFd6e2f0),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: selIndex == index
                        ? const [
                            Color(0xFF75BFFF),
                            Color(0xFF48AAFF),
                            Color(0xFF479DFF),
                            Color(0xFF3B91F1),
                          ]
                        : const [
                            Color(0xFFF5F8FF),
                            Color(0xFFECF3FF),
                          ],
                  )),
              child: Text(
                tabs[index],
                style: TextStyle(
                    color: selIndex == index
                        ? Colors.white
                        : const Color(0xff95A3C4),
                    fontSize: 14.px),
              ),
            ),
          );
        })
      ]),
      Expanded(
          child: MessageTabChildPage(
        type: types[selIndex],
        key: _pageKey,
      ))
    ]);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
