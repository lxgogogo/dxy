import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/index/page_index.dart';
import 'package:holdem/page/message/page_message.dart';
import 'package:holdem/page/mine/page_login.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/size_fit.dart';

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
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TabBar Demo'),
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xff008EFF),
        unselectedItemColor: const Color(0xff3B5078),
        showSelectedLabels: true, // 取消显示选中项的标签
        showUnselectedLabels: true, // 取消显示未选中项的标签
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
              width: 38.px,
              height: 40.px,
            ),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 1
                  ? 'assets/images/tab_forum_sel.png'
                  : 'assets/images/tab_forum.png',
              width: 38.px,
              height: 40.px,
            ),
            label: '论坛',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 2
                  ? 'assets/images/tab_message_sel.png'
                  : 'assets/images/tab_message.png',
              width: 38.px,
              height: 40.px,
            ),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 3
                  ? 'assets/images/tab_me_sel.png'
                  : 'assets/images/tab_me.png',
              width: 38.px,
              height: 40.px,
            ),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('a');
    return Center(
      child: Container(
          width: 150.px,
          height: 54.px,
          padding: EdgeInsets.all(10.px),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //flutter 上下颜色渐变
            //#F9CF3A, #FFD43E00
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEEF7FE),
                Color(0xFFDDEDFA),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(190, 214, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(194, 216, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(193, 215, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 4.0,
                spreadRadius: -4.0,
                offset: Offset(0.0, 4.0),
              ),
              BoxShadow(
                color: Color.fromRGBO(148, 197, 239, 0.74),
                blurRadius: 9.4,
                spreadRadius: -9.4,
                offset: Offset(0.0, -4.0),
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(26.px)),
          ),
          child: Text(
            '进阶策略',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF56748F),
                fontSize: 28.px,
                fontWeight: FontWeight.bold),
          )),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 2'),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 3'),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 4'),
    );
  }
}
