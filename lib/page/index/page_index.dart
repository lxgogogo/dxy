import 'package:flutter/material.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentTabIndex = 0;
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
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
                          ? Image.asset( 'assets/images/tab_sel.png',
                              width: 30.px,
                              height: 6.px)
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
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: kBgColor, // 设置背景颜色为灰色
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_top.png', // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
