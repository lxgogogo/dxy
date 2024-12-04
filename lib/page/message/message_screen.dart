import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';

part 'message_controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
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
  final _pageKey = GlobalKey<MessageChildViewState>();

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
        content: MessageChildView(type: types[i]),
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
      labelStyle: TextStyle(height: 1, color: forumAppMainColor, fontSize: 16.px, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(height: 1, color: tabTitleUnselectColor, fontSize: 16.px, fontWeight: FontWeight.w400),
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
          title: Text(
            '消息',
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: 16.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: detail(),
      ),
    );
  }

  Widget detail() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
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
                    padding: EdgeInsets.symmetric(horizontal: 17.px),
                    margin: EdgeInsets.only(right: 12.px, bottom: 12.px),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.px),
                        boxShadow: [
                          BoxShadow(
                            color: selIndex == index ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
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
                      style:
                          TextStyle(color: selIndex == index ? Colors.white : const Color(0xff95A3C4), fontSize: 14.px),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
        Expanded(
            child: MessageChildView(
          type: types[selIndex],
          key: _pageKey,
        ))
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
