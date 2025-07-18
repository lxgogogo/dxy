import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../services/index.dart';
import '../../../stores/config_store.dart';
import '../../../utils/dialog_util.dart';
import '../../../utils/track_utils.dart';
import '../../../widget/item_feed.dart';
import '../../../widget/report_sheet.dart';
import '../../../widget/special_classic_footer.dart';

class FeedListChildView extends StatefulWidget {
  const FeedListChildView({super.key});

  @override
  State<FeedListChildView> createState() => FeedListChildViewState();
}

class FeedListChildViewState extends State<FeedListChildView> with AutomaticKeepAliveClientMixin {
  late int tabIdValue;

  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;
  int pageId = 0;
  String boardSort = NetRequest.BOARD_SORT_TIME;
  List<BoardBean> boardPostList = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();

  StreamSubscription? tabEvent;
  StreamSubscription? postFeedEvent;
  StreamSubscription? refreshNumEventObs;

  void _onRefresh() async {
    EventBusUtil.of.fire(EventRefreshFeedTabs());
    pageNum = 1;
    isLoaded = false;
    setState(() {});
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

  void refreshData(int id, String order) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0.0);
    }
    pageId = id;
    tabIdValue = id;
    boardSort = order;
    _onRefresh();
  }

  void refreshFilter(String order) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0.0);
    }
    boardSort = order;
    _onRefresh();
  }

  @override
  void initState() {
    tabIdValue = pageId; //widget.tabId;
    super.initState();

    reqListData();

    tabEvent = EventBusUtil.of.on<EventChangeMainTab>().listen((event) {
      if (event.tabIndex == 1) {
        _onRefresh();
      }
    });
    postFeedEvent = EventBusUtil.of.on<EventChangeMainTab>().listen((event) {
      boardSort = NetRequest.BOARD_SORT_TIME;
      _onRefresh();
    });
    refreshNumEventObs = EventBusUtil.of.on<EventRefreshNum>().listen((event) {
      final index = boardPostList.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        boardPostList[index].favoriteCount = event.favoriteCount;
        boardPostList[index].likeCount = event.likeCount;
        boardPostList[index].commentCount = event.commentCount;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    tabEvent?.cancel();
    postFeedEvent?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  reqListData({bool showLoading = false}) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;
    params['ordered'] = boardSort;

    Map<String, Object> filters = {};
    final boardId = tabIdValue == 0 ? '' : tabIdValue.toString();
    if (boardId.isNotEmpty) {
      filters['boardId'] = boardId;
    }
    params['filters'] = filters;
    //tabIdValue = 0全部板块,不传boardId
    try {
      int recordsSize = 0;
      await NetRequest().getThreadListByBoard(params, showLoading: showLoading, (data) {
        BoardList boardList = BoardList.fromJson(data);
        recordsSize = boardList.list?.length ?? 0;
        if (pageNum == 1) {
          boardPostList.clear();
        }
        boardPostList.addAll(boardList.list ?? []);
      });
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
      isLoaded = true;
      setState(() {});
    }
  }

  Future<void> _onShield(int id) async {
    final success = await NetRequest().shieldFeed(id);
    if (success) {
      pageNum = 1;
      reqListData();
    }
  }

  Future<void> _onShieldUser(int id) async {
    final success = await NetRequest().shieldUser(id);
    if (success) {
      pageNum = 1;
      reqListData();
    }
  }

  Future<void> _onReport(int id, int userId) async {
    final reportTypes = await ConfigStore.of.getReportTypes();
    Get.bottomSheet(
      ReportSheet(
        reportTypes: reportTypes,
        onReport: (int index) async {
          try {
            final res = await CommonService.of.reportCreate(
              'thread',
              id,
              userId,
              reason: reportTypes[index].value,
            );
            if (res.isSuccess) {
              DialogUtil.showToast('举报成功，我们将会在24小时内受理');
            }
          } finally {
            Get.back();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!isLoaded) {
      return const SizedBox();
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: boardPostList.isNotEmpty == true || !noMore,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      scrollController: scrollController,
      child: boardPostList.isNotEmpty
          ? CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int i) {
                      return FeedItem(
                        boardPostList[i],
                        onShield: () {
                          if (boardPostList[i].id != null) {
                            _onShield(boardPostList[i].id!);
                          }
                        },
                        onShieldUser: () {
                          if (boardPostList[i].user?.id != null) {
                            _onShieldUser(boardPostList[i].user!.id!);
                          }
                        },
                        onReport: () {
                          if (boardPostList[i].id != null && boardPostList[i].user?.id != null) {
                            _onReport(boardPostList[i].id!, boardPostList[i].user!.id!);
                          }
                        },
                        onTap: () => TrackUtils.trackEvent(
                          userLogType: '108002',
                          params: boardPostList[i].id,
                        ),
                      );
                    },
                    childCount: boardPostList.length,
                  ),
                ),
              ],
            )
          : const Center(child: NoDataView()),
    ).scrollToTopWrapper(
      scrollController,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
