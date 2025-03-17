import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/board_list.dart';
import '../../../model/collect_page_model.dart';
import '../../../model/comment_list.dart';
import '../../../utils/net_request.dart';
import '../../../widget/no_data.dart';

class MineChildView extends StatefulWidget {
  final int tabIndex;

  const MineChildView({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MineChildViewState createState() => _MineChildViewState();
}

class _MineChildViewState extends State<MineChildView> with TickerProviderStateMixin {
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool _isMounted = false;

  List<BoardBean> boardPostList = [];
  List<CollectModel> collectList = [];
  List<CommentBean> commentDataList = [];
  final ScrollController _listController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool loaded = false;

  reqListData({bool showLoading = true}) async {
    int recordsSize = 0;
    try {
      if (widget.tabIndex == 0) {
        Map<String, dynamic> params = {};
        params['pageNum'] = pageNum;
        params['pageSize'] = pageSize;
        params['ordered'] = NetRequest.BOARD_SORT_TIME;

        Map<String, dynamic> filters = {};
        var ownerId = UserStore.of.user?.id;
        filters['ownerId'] = ownerId;
        params['filters'] = filters;
        await NetRequest().getThreadListByBoard(params, showLoading: showLoading, (data) {
          BoardList dataList = BoardList.fromJson(data);
          recordsSize = (dataList.list ?? []).length;
          if (pageNum == 1) {
            boardPostList.clear();
          }
          boardPostList.addAll(dataList.list ?? []);
        });
      } else if (widget.tabIndex == 1) {
        //收藏
        await NetRequest().userFavoriteList(pageNum, pageSize, '', showLoading: showLoading, (data) {
          CollectPageModel dataList = CollectPageModel.fromJson(data);
          recordsSize = (dataList.list ?? []).length;
          if (pageNum == 1) {
            collectList.clear();
          }
          collectList.addAll(dataList.list ?? []);
        });
      } else if (widget.tabIndex == 2) {
        //评论
        await NetRequest().userCommentList(pageNum, pageSize, '', showLoading: showLoading, (data) {
          CommentList dataList = CommentList.fromJson(data);
          recordsSize = (dataList.list ?? []).length;
          if (pageNum == 1) {
            commentDataList.clear();
          }
          commentDataList.addAll(dataList.list ?? []);
        });
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
    } catch (e) {
      _refreshController.loadFailed();
    } finally {
      loaded = true;
      if (pageNum == 1) {
        if (_listController.hasClients) {
          _listController.jumpTo(0);
        }
      }
      setState(() {});
    }
  }

  void _onRefresh() async {
    pageNum = 1;
    reqListData(showLoading: false);
  }

  void _onLoading() async {
    if (noMore) {
      _refreshController.loadNoData();
      return;
    }
    pageNum++;
    reqListData(showLoading: false);
  }

  StreamSubscription? eventSub1;
  StreamSubscription? eventSub2;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    reqListData();

    eventSub1 = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      _onRefresh();
    });
    eventSub2 = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    eventSub1?.cancel();
    eventSub2?.cancel();
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return SlidableAutoCloseBehavior(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: loaded &&
                    (widget.tabIndex == 0
                        ? boardPostList.isEmpty
                        : widget.tabIndex == 1
                            ? collectList.isEmpty
                            : commentDataList.isEmpty)
                ? const Center(child: NoDataView())
                : const Center(child: NoDataView()),
          ),
        );
      },
    );
  }
}
