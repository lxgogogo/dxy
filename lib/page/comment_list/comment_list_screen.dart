import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/item_comment.dart';
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
  int pageSize = 20;
  bool noMore = false;
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

  reqListData() async {
    try {
      int recordsSize = 0;
      await NetRequest().commentList({
        'pageNum': pageNum,
        'pageSize': pageSize,
        'filters': {'relType': widget.relType, 'relId': widget.relId}
      }, (data) {
        if (mounted) {
          List<CommentBean> dataList =
              List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
          recordsSize = dataList.length;
          if (pageNum == 1) {
            comments.clear();
          }
          comments.addAll(dataList);
          commentCountsText = '(${comments.length})';
        }
        if (pageNum == 1) {
          _refreshController.refreshCompleted();
          if (recordsSize < pageSize) {
            noMore = true;
            _refreshController.loadNoData();
          } else {
            noMore = false;
            _refreshController.resetNoData();
          }
        } else {
          if (recordsSize < pageSize) {
            noMore = true;
            _refreshController.loadNoData();
          } else {
            noMore = false;
            _refreshController.loadComplete();
          }
        }
      });
    } catch (e) {
      _refreshController.loadFailed();
    } finally {
      loaded = true;
      setState(() {});
    }
  }

  void _onRefresh() async {
    pageNum = 1;
    reqListData();
  }

  void _onLoading() async {
    if (noMore) {
      _refreshController.loadNoData();
      return;
    }
    pageNum++;
    reqListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: content());
  }

  content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
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
