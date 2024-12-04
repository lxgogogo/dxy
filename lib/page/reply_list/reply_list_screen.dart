import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'reply_list_controller.dart';

class ReplyListScreen extends StatefulWidget {
  final int id;
  final CommentBean commentBean;
  const ReplyListScreen({super.key,required this.id,required this.commentBean});

  @override
  State<ReplyListScreen> createState() => _ReplyListScreenState();
}

class _ReplyListScreenState extends State<ReplyListScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<CommentBean> comments = [];
  bool loaded = false;
  int pageNum = 1;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    reqListData();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      reqListData();
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
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
      header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
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
