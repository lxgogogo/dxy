import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/page/index/item_article.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/PostListView.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:intl/intl.dart';

class GameCalendarPage extends StatefulWidget {
  int id;
  GameCalendarPage({super.key, required this.id});

  @override
  State<GameCalendarPage> createState() => _GameCalendarPageState();
}

class _GameCalendarPageState extends State<GameCalendarPage> {
  List<ArticleBean> articles = [];
  List<ArticleBean> videos = [];
  List<BoardBean> boardPostList = [];

  @override
  void initState() {
    super.initState();
    reqData();
  }

  reqData() {
    NetRequest().competitionRelated({"id": widget.id}, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data['articles'].map((article) => ArticleBean.fromJson(article)));
      List<ArticleBean> videoList = List<ArticleBean>.from(
          data['videos'].map((article) => ArticleBean.fromJson(article)));
      List<BoardBean> boardList = List<BoardBean>.from(
          data['threads'].map((article) => BoardBean.fromJson(article)));
      if (mounted) {
        setState(() {
          articles = dataList;
          videos = videoList;
          boardPostList = boardList;
        });
      }
    });

    NetRequest().articleDetail({'id': widget.id}, (data) {
      if (mounted) {
        // setState(() {
        //   articleDetailBean = ArticleDetailBean.fromJson(data);
        //   loaded = true;
        // });
      }
    });
  }

  calendar() {
    final DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    // final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final List<Widget> days = [];

    // 添加星期几标题
    days.addAll(['日', '一', '二', '三', '四', '五', '六'].map((day) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Center(
            child: Text(
          day,
          style: TextStyle(color: const Color(0xffAAB2C0)),
        )),
      );
    }).toList());

    // 找到本月第一天是星期几
    int startDay = DateTime(year, month, 1).weekday % 7;

    // 添加空白格子
    for (int i = 0; i < startDay; i++) {
      days.add(Container());
    }

    // 添加本月的每一天
    for (int day = 1; day <= daysInMonth; day++) {
      bool isSelected = false;
      if (day == 20) {
        isSelected = true;
      }
      days.add(CustomCalendarItem(day: day, selected: isSelected));
    }

    // 确保每行有 7 个元素
    while (days.length % 7 != 0) {
      days.add(Container());
    }

    // 创建日历表格
    return Table(
      children: [
        for (int i = 0; i < days.length ~/ 7; i++)
          TableRow(
            children: days.skip(i * 7).take(7).toList(),
          ),
      ],
    );
  }

  contentItem(int index) {
    return ArticleItem(
      article: articles[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: kBgColor,
              // elevation: 0, // 去除导航条的阴影
              title: Text('德州赛事'),
            ),
            backgroundColor: kBgColor,
            // ignore: unnecessary_null_comparison
            body: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.px),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.px)),
                  child: calendar(),
                ),
                SizedBox(height: 6.px,),
                Row(
                  children: [
                    SizedBox(width: 20.px,),
                    Text(
                      '相关资讯',
                      style: TextStyle(
                          color: const Color(0xff2A2A2A),
                          fontSize: 14.px,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),

                ...List.generate(articles.length, (index) {
                  return contentItem(index);
                }),
                // ListView.builder(
                //   itemBuilder: (c, i) => contentItem(i),
                //   // itemExtent: 160.0,
                //   itemCount: articles.length,
                // ),
                GridView.builder(
                  padding:
                      EdgeInsets.only(left: 12.px, right: 12.px, top: 12.px),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8.px,
                    mainAxisSpacing: 8.px,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: videos.length,
                  itemBuilder: (contxt, indx) {
                    return VideoItem(
                      article: videos[indx],
                      isBanner: false,
                    );
                  },
                ),
                // ...List.generate(boardPostList.length, (index){
                //   return PostListItemView(context, index, true, boardPostList[index]);
                // })
              ],
            ))));
  }
}

class CustomCalendarItem extends StatelessWidget {
  final int day;
  final bool selected;

  CustomCalendarItem({required this.day, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
              color: selected ? Colors.white : const Color(0xff2c2c2c),
              fontSize: 16),
        ),
      ),
    );
  }
}
