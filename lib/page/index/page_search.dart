import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/index/page_search_result.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/page_web_fit.dart';
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
    return WebFitPage(
        child: Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
                    if (items.contains(key)) {
                      items.remove(key);
                    }
                    NetRequest().indexList({
                      'pageNum': 1,
                      'pageSize': 10,
                      'filters': {
                        'q': key,
                      }
                    }, (data) {
                      if (data['list'].length == 0) {
                        ToastUtils.showToast("暂无结果");
                      } else {
                        items.insert(0, key);
                        StorageUtil().prefs!.setStringList('search', items);
                        Get.to(SearchResultPage(
                          keyword: key,
                        ));
                      }
                    });
                  });

                  // StorageUtil().prefs!.setString('token', data['token']);
                }
              },
              child: Text('搜索',
                  style: TextStyle(
                      color: const Color(0xff249CFC), fontSize: 15.px)))
          // GestureDetector(child: Text('搜索'),)
        ],
      ),
      body: Container(
        // color: Colors.red,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F7FC), Color(0xFFE4EEF9), Color(0xFFE4EEF9)],
        )),
        child: Column(
          children: [
            SizedBox(
              height: 8.px,
            ),
            // Container(
            //   width: 351.px,
            //   height: 45.px,
            //   margin: EdgeInsets.only(bottom: 20),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(22.5.px),
            //     boxShadow:  const [
            //       BoxShadow(
            //         color: Color(0x80BFD2E2),
            //         offset: Offset(0, 4),
            //         blurRadius: 8,
            //       ),
            //     ],
            //     image: DecorationImage(
            //           image: AssetImage('assets/images/logout_btn.png'),
            //           fit: BoxFit.contain)),
            // ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.px),
              padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 16.px),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5F8FF),
                    Color(0xFFECF3FF),
                  ],
                ),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  width: 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD6E2F0),
                    offset: Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '搜索历史',
                        style: TextStyle(
                            color: const Color(0xff95A3C4), fontSize: 12.px),
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
                    ],
                  ),
                  SizedBox(
                    height: 8.px,
                  ),
                  Wrap(
                    spacing: 8.px,
                    runSpacing: 8.px,
                    alignment: WrapAlignment.start,
                    children: [
                      ...List.generate(items.length, (index) {
                        // return Text(items[index],style: TextStyle(color: const Color(0xff7282A0)));
                        return GestureDetector(
                          onTap: () {
                            Get.to(SearchResultPage(
                              keyword: items[index],
                            ));
                          },
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('删除'),
                                    content: const SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text('确认删除当前搜索记录?'),
                                          // Text('你可以在这里添加更多的内容.')
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('取消'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('确认'),
                                        onPressed: () {
                                          // 在这里添加确认操作的代码
                                          setState(() {
                                            items.removeAt(index);
                                            StorageUtil()
                                                .prefs!
                                                .setStringList('search', items);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.px, vertical: 5.px),
                            decoration: BoxDecoration(
                                color: Color(0xffF8FCFF),
                                borderRadius: BorderRadius.circular(13.px)),
                            child: Text(
                              items[index],
                              style: TextStyle(color: const Color(0xff7282A0)),
                            ),
                          ),
                        );
                      })
                    ],
                  )
                ],
              ),
            ),
            // Expanded(
            //     child: ListView.builder(
            //   itemBuilder: (c, i) => listDataItem(i),
            //   // itemExtent: 160.0,
            //   itemCount: items.length,
            // ))
          ],
        ),
      ),
    ));
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
              onTap: () {
                Get.to(SearchResultPage(
                  keyword: items[index],
                ));
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
