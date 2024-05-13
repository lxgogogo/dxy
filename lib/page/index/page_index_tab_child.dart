import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class IndexTabChildPage extends StatefulWidget {
  String type;
  IndexTabChildPage({super.key, required this.type});

  @override
  State<IndexTabChildPage> createState() => _IndexTabChildPageState();
}

class _IndexTabChildPageState extends State<IndexTabChildPage> {
  List<ArticleBean> articles = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    reqListData();
  }

  reqListData() {
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'categoryAlias': widget.type //'article'
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data['list'].map((article) => ArticleBean.fromJson(article)));

      if (mounted) {
        setState(() {
          articles = dataList;
        });
      }
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return content();
  }

  Widget content() {
    if (widget.type == 'book') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.px),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8.px,
              mainAxisSpacing: 8.px,
            ),
            itemBuilder: (c, i) => contentItem(i),
            itemCount: articles.length,
          ));
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
    if (widget.type == 'book') {
      return BookItem(
        article: articles[index],
      );
    }
    return VideoItem(
      article: articles[index],
    );
  }
}
