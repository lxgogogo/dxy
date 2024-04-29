import 'package:flutter/material.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
        extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 设置导航条背景透明
          elevation: 0, // 去除导航条的阴影
          title: Text('hhh'),
        ),
        body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_top.png', // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: kBgColor, // 设置背景颜色为灰色
            child: Column(
              children: [
                SafeArea(
                    child: SizedBox(
                  height: 0.px,
                )),
                Expanded(child: Container())
              ],
            ),
          ),
        ],
      ),
        );
  }
}
