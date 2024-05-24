import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/index/page_search_result.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/widget/search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> items = [];
  late String key;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    List<String>? list = StorageUtil().prefs!.getStringList('search');
    setState(() {
      items = list ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      appBar: AppBar(
        automaticallyImplyLeading:false,
        titleSpacing: 0.0,
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
        title: CSearchBar(
          onChanged: (value) {
            setState(() {
              key = value;
            });
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (key != null) {
                  setState(() {
                    items.insert(0, key);
                    StorageUtil().prefs!.setStringList('search', items);
                    Get.to(SearchResultPage(keyword: key,));
                  });

                  // StorageUtil().prefs!.setString('token', data['token']);
                }
              },
              child: Text('搜索',
                  style: TextStyle(
                      color: const Color(0xff3B5078), fontSize: 15.px)))
          // GestureDetector(child: Text('搜索'),)
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 8.px,
          ),
          Row(
            children: [
              SizedBox(
                width: 16.px,
              ),
              Text(
                '搜索历史',
                style:
                    TextStyle(color: const Color(0xff333333), fontSize: 15.px),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    items = [];
                    StorageUtil().prefs!.setStringList('search', items);
                  });
                },
                child: Image.asset('assets/images/label_del.png',
                    width: 16.px, height: 16.px),
              ),
              SizedBox(
                width: 16.px,
              )
            ],
          ),
          SizedBox(
            height: 8.px,
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
      height: 36.px,
      padding: EdgeInsets.symmetric(horizontal: 16.px),
      child: Row(
        children: [
          Image.asset(
            'assets/images/clock.png',
            width: 16.px,
            height: 16.px,
          ),
          SizedBox(
            width: 4.px,
          ),
          Expanded(
            child: GestureDetector(
              onTap: (){
                Get.to(SearchResultPage(keyword: items[index],));
              },
              child: Text(
                items[index],
                style:
                    TextStyle(color: const Color(0xff666666), fontSize: 15.px),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                items.removeAt(index);
                StorageUtil().prefs!.setStringList('search', items);
              });
            },
            child: Image.asset(
              'assets/images/delete.png',
              width: 16.px,
              height: 16.px,
            ),
          ),
        ],
      ),
    );
  }
}
