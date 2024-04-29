import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/navi_back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            // 登录按钮点击事件
            Get.back();
          },
        ),
        title: CSearchBar(),
        actions: [
          TextButton(onPressed: () => {}, child: Text('搜索'))
          // GestureDetector(child: Text('搜索'),)
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [Text('热门搜索'), Text('清空历史记录')],
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (c, i) => listDataItem(i),
            // itemExtent: 160.0,
            itemCount: items.length,
          ))
        ],
      ),
    );
  }

  Widget listDataItem(int index) {
    return Container(
      child: Row(children: [
        Image.asset(
            'assets/images/clock.png',
            width: 16.px,
            height: 16.px,
          ),
          Expanded(child: Text('hello world'),),
          Image.asset(
            'assets/images/delete.png',
            width: 16.px,
            height: 16.px,
          ),
          
        
      ],),
    );
  }
}
