import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RepliesPage extends StatefulWidget {
  int id;
  CommentBean commentBean;
  RepliesPage({super.key,required this.id,required this.commentBean});

  @override
  State<RepliesPage> createState() => _RepliesPageState();
}

class _RepliesPageState extends State<RepliesPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<CommentBean> comments = [];
  bool loaded = false;
  int pageNum = 1;

  var actionEventBus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    reqListData();
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.refreshForumPostDetail.eventBusTypeName) {
        NetRequest().commentList({
          'pageNum': 1,
          'pageSize': comments.length + 1,
          'filters': {'relType': 'content', 'relId': widget.id}
        }, (data) {
          if (mounted) {
            List<CommentBean> dataList = List<CommentBean>.from(
                data['list'].map((comment) => CommentBean.fromJson(comment)));
            setState(() {
              comments = dataList;
              loaded = true;
            });
          }
        });
      }
    });
  }

  reqListData() {
    NetRequest().commentList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'relType': 'comment', 'relId': widget.id}
    }, (data) {
      if (mounted) {
        List<CommentBean> dataList = List<CommentBean>.from(
            data['list'].map((comment) => CommentBean.fromJson(comment)));
        setState(() {
          comments = dataList;
          loaded = true;
        });
      }
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
    return BackgroundContainer(
      child: Scaffold(
          appBar: AppBar(
            // elevation: 0, // 去除导航条的阴影
            title: Text('全部回复'),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: content()),
    );
  }

  content() {
    if (comments.length == 0)
      return Center(
        child: NoDataView(),
      );
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
        itemCount: comments.length,
      ),
    );
  }

  contentItem(i) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.px),
      child: CommentItem(
      commentBean: comments[i],
      isReply: true,
    ),);
  }
}
