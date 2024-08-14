import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/index/page_index.dart';
import 'package:holdem/page/message/page_message.dart';
import 'package:holdem/page/mine/page_login.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/page_web_fit.dart';

import '../utils/eventbus/EventBusAction.dart';
import '../utils/eventbus/EventBusManager.dart';
import 'forum/page_forum_tab.dart';
import 'mine/page_mine.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    IndexPage(),
    ForumTabPage(),
    MessagePage(),
    MinePage()
  ];

  var actionEventBus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //接受退出登录之后首页tab通知切换到0位置
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.noticeMainTabSwitchHome.eventBusTypeName) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
      // appBar: AppBar(
      //   title: Text('TabBar Demo'),
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child:BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xff008EFF),
        unselectedItemColor: const Color(0xff9CACC9),
        showSelectedLabels: true, // 取消显示选中项的标签
        showUnselectedLabels: true, // 取消显示未选中项的标签
        useLegacyColorScheme: false,
        onTap: (int index) {
          if ((index == 2 || index == 3) && !Global().hasLogin) {
            Get.to(LoginPage());
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 0
                  ? 'assets/images/tab_index_sel.png'
                  : 'assets/images/tab_index.png',
              width: 20.px,
              height: 20.px,
            ),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 1
                  ? 'assets/images/tab_forum_sel.png'
                  : 'assets/images/tab_forum.png',
              width: 20.px,
              height: 20.px,
            ),
            label: '论坛',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 2
                  ? 'assets/images/tab_message_sel.png'
                  : 'assets/images/tab_message.png',
              width: 20.px,
              height: 20.px,
            ),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 3
                  ? 'assets/images/tab_me_sel.png'
                  : 'assets/images/tab_me.png',
              width: 20.px,
              height: 20.px,
            ),
            label: '我的',
          ),
        ],
      )),
    ));
  }
}
