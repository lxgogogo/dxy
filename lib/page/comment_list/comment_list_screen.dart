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

part 'comment_list_controller.dart';

class CommentListScreen extends StatefulWidget {
  final int relId;
  final String relType;

  const CommentListScreen({super.key, required this.relId, required this.relType});

  @override
  State<CommentListScreen> createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  List<CommentBean> comments = [];
  bool loaded = false;
  String commentCountsText = '';

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
      'filters': {'relType': widget.relType, 'relId': widget.relId}
    }, (data) {
      if (mounted) {
        List<CommentBean> dataList =
            List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
        if (pageNum == 1) {
          comments = dataList;
        } else {
          comments.addAll(dataList);
        }
        commentCountsText = '(${comments.length})';
        loaded = true;
        setState(() {});
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
    return BackgroundContainer(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              '评论',
              style: TextStyle(
                color: const Color(0xff2c2c2c),
                fontSize: 16.px,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Image.asset(
                'assets/images/back.png',
                width: 22.px,
                height: 22.px,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: content()),
    );
  }

  content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: comments.isNotEmpty
          ? ListView.builder(
              itemBuilder: (c, i) => contentItem(i),
              // itemExtent: 160.0,
              itemCount: comments.length,
            )
          : const NoCommentView(),
    );
  }

  contentItem(i) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.px),
      child: CommentItem(
        commentBean: comments[i],
        relType: widget.relType,
      ),
    );
  }
}
