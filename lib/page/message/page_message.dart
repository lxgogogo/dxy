import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
        extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 设置导航条背景透明
          elevation: 0, // 去除导航条的阴影
          title: Text('Message'),
        ),);
  }
}