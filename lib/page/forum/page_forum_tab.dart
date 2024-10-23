import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/page/forum/page_publish_posts.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../model/board_info.dart';
import '../../utils/constants.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
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
  int selIndex = 0;
  int filterIndex = 0;
  final _pageKey = GlobalKey<ForumTabChildPageState>();

  var actionEventBus;
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
    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.updateBoardTabData.eventBusTypeName) {
        if (mounted) {
          getPlateData();
        }
      }
    });
  }

  void getPlateData() {
    NetRequest().getBoardData((data) {
      List<BoardInfo> dataList =
          List<BoardInfo>.from(data.map((plate) => BoardInfo.fromJson(plate)));
      if (mounted) {
        setState(() {
          // if (forumParentTabs.isNotEmpty) {
          //   forumParentTabs.clear();
          //   forumParentTabs.add(TabData(
          //     index: 0,
          //     title: Tab(
          //       child: Text('全部板块'),
          //     ),
          //     content: ForumTabChildPage(tabId: 0),
          //   ));
          // }
          boardInfoList = dataList;
          // for (int i = 0; i < dataList.length; i++) {
          //   BoardInfo boardInfo = dataList[i];
          //   forumParentTabs.add(TabData(
          //     index: i + 1,
          //     title: Tab(
          //       child: Text(boardInfo.name!),
          //     ),
          //     content: ForumTabChildPage(tabId: boardInfo.id!),
          //   ));
          // }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent, // 设置导航条背景透明
        // elevation: 0, // 去除导航条的阴影
        title: Text('论坛'),
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/order.png',
              width: 20.px,
              height: 20.px,
            ),
            onPressed: () {
              _showMenuDialog(context);
              // _showPopupMenu(context);
              // Get.to(SettingsPage());
            },
          ),
        ],
      ),
      // body: SafeArea(child: getTabView()),
      body: detail(),
      // body: Container(color: Colors.transparent,),
      backgroundColor: sortBtnBgtColor,
      floatingActionButton: bottomFloatingButton(),
    );
  }

  void _showMenuDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 可以点击外部区域关闭弹窗
      barrierLabel: '',
      barrierColor: Colors.transparent, // 背景遮罩颜色
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topRight, // 弹窗位置
          child: Container(
            width: 90.px,
            height: 133.px,
            margin: EdgeInsets.only(top: 45.px, right: 5), // 自定义位置
            padding: EdgeInsets.only(top:10.px,bottom: 13.px),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/pop_menu_bg.png'),
                  fit: BoxFit.cover),
            ),
            child: Column(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      filterIndex = 0;
                    });
                    String order = 'time';
                    _pageKey.currentState?.refreshData(0, order);
                    Navigator.of(context).pop(); // 关闭弹窗
                  },
                  child: Center(
                      child: Text(
                    '时间最新',
                    style: TextStyle(
                        color: filterIndex == 0
                            ? Color(0xff249CFC)
                            : Color(0xff95A3C4)),
                  )),
                )),
                Container(
                  width: 90.px,
                  height: 0.5.px,
                  color: const Color(0xffE7F0FA),
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      filterIndex = 1;
                    });
                    String order = 'comment';
                    _pageKey.currentState?.refreshData(0, order);
                    Navigator.of(context).pop(); // 关闭弹窗
                  },
                  child: Center(
                      child: Text(
                    '回帖最多',
                    style: TextStyle(
                        color: filterIndex == 1
                            ? Color(0xff249CFC)
                            : Color(0xff95A3C4)),
                  )),
                )),
                Container(
                  width: 90.px,
                  height: 0.5.px,
                  color: const Color(0xffE7F0FA),
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      filterIndex = 2;
                    });
                    String order = 'like';
                    _pageKey.currentState?.refreshData(0, order);
                    Navigator.of(context).pop(); // 关闭弹窗
                  },
                  child: Center(
                      child: Text(
                    '点赞最多',
                    style: TextStyle(
                        color: filterIndex == 2
                            ? Color(0xff249CFC)
                            : Color(0xff95A3C4)),
                  )),
                )),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget detail() {
    int tabId = 0;
    if (selIndex != 0) {
      tabId = boardInfoList[selIndex - 1].id!;
    }
    return Column(
      children: [
        SizedBox(
          height: 30.px,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 18.px,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selIndex = 0;
                    });
                    String order = filterIndex == 0
                        ? 'time'
                        : filterIndex == 1
                            ? 'comment'
                            : 'like';
                    _pageKey.currentState?.refreshData(0, order);
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
                            color: selIndex == 0
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
                          colors: selIndex == 0
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
                      '全部',
                      style: TextStyle(
                          color: selIndex == 0
                              ? Colors.white
                              : const Color(0xff95A3C4),
                          fontSize: 14.px),
                    ),
                  ),
                ),
                ...List.generate(boardInfoList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selIndex = index + 1;
                      });
                      String order = filterIndex == 0
                          ? 'time'
                          : filterIndex == 1
                              ? 'comment'
                              : 'like';
                      _pageKey.currentState
                          ?.refreshData(boardInfoList[selIndex - 1].id!, order);
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
                              color: selIndex == index + 1
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
                            colors: selIndex == index + 1
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
                        boardInfoList[index].name!,
                        style: TextStyle(
                            color: selIndex == index + 1
                                ? Colors.white
                                : const Color(0xff95A3C4),
                            fontSize: 14.px),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
        // ForumTabChildPage(
        //   tabId: tabId,
        //   key: _pageKey,
        // )
        Expanded(
            child: ForumTabChildPage(
          tabId: tabId,
          key: _pageKey,
        ))
      ],
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
            fontWeight: FontWeight.w400),
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
        Get.to(PublishPostsPage(boardInfoList: boardInfoList));
      },
      shape: CircleBorder(),
    );
  }
}

class CustomDivider extends PopupMenuEntry<String> {
  final String value;

  CustomDivider(this.value);

  @override
  double get height => 1.0;

  // @override
  // bool represents(String value) => this.value == value;

  @override
  State<CustomDivider> createState() => _CustomDividerState();

  @override
  bool represents(String? value) {
    // TODO: implement represents
    throw UnimplementedError();
  }
}

class _CustomDividerState extends State<CustomDivider> {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Color(0xffE7F0FA),
    );
  }
}
