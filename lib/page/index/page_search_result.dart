import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchResultPage extends StatefulWidget {
  String keyword;
  SearchResultPage({super.key, required this.keyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<ArticleBean> articles = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int pageNum = 1;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    reqListData();
  }

  reqListData() {
    NetRequest().indexList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {
        'q': widget.keyword,
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data['list'].map((article) => ArticleBean.fromJson(article)));

      if (mounted) {
        setState(() {
          if (pageNum == 1) {
            articles = dataList;
          } else {
            articles.addAll(dataList);
          }
          loaded = true;
        });
      }
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
    });
  }

  void _onRefresh() async {
    setState(() {
      pageNum = 1;
    });
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        // title: Text('hhh'),
      ),
      body:content());
  }

  Widget content() {
    if (loaded && articles.length == 0) {
      return Center(child: NoDataView(),);
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => contentItem(i),
        // itemExtent: 160.0,
        itemCount: articles.length,
      ),
    );
  }

  contentItem(int index) {
    return VideoItem(
      article: articles[index],
    );
  }
}
