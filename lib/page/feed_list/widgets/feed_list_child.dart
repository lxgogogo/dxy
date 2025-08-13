import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../gen/assets.gen.dart';
import '../../../services/index.dart';
import '../../../stores/config_store.dart';
import '../../../utils/dialog_util.dart';
import '../../../utils/track_utils.dart';
import '../../../widget/common_operations_sheet.dart';
import '../../../widget/item_feed.dart';
import '../../../widget/report_sheet.dart';

class FeedListChildView extends StatefulWidget {
  final int boardId;

  const FeedListChildView({super.key, required this.boardId});

  @override
  State<FeedListChildView> createState() => FeedListChildViewState();
}

class FeedListChildViewState extends State<FeedListChildView> {
  bool _isDown = true;

  List<String> filters = [
    '最近更新',
    '热度最高',
    '回帖最多',
    '点赞最多',
  ];
  List<String> filterCode = [
    'time',
    'popular',
    'comment',
    'like',
  ];
  int filterIndex = 0;

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
    if (mounted) {
      setState(() {});
    }
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
    super.initState();
    pageId = widget.boardId;
    tabIdValue = widget.boardId;
    boardSort = filterCode[filterIndex];
    tabIdValue = pageId; //widget.tabId;
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
        if (mounted) {
          setState(() {});
        }
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
      if (mounted) {
        setState(() {});
      }
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
    if (!isLoaded) {
      return const CupertinoActivityIndicator(color: Colors.grey);
    }
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: boardPostList.isNotEmpty == true || !noMore,
      controller: _refreshController,
      // onRefresh: _onRefresh,
      onLoading: _onLoading,
      scrollController: scrollController,
      child: boardPostList.isNotEmpty
          ? CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            _isDown = false;
                            if (mounted) {
                              setState(() {});
                            }
                            showCommonOperationsSheet(
                                items: filters,
                                itemBuilder: (int index, bool hasSelected) {
                                  return Text(
                                    filters[index],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: hasSelected ? '#333333'.hexColor : '#666666'.hexColor,
                                      fontWeight: hasSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                                selectedIndex: filterIndex,
                                onSelectItem: (int index) {
                                  if (filterIndex != index) {
                                    _isDown = false;
                                    filterIndex = index;
                                    String order = filterCode[filterIndex];
                                    refreshFilter(order);
                                  }
                                },
                                endAction: () {
                                  _isDown = true;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filters[filterIndex],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: '#666666'.hexColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                if (_isDown)
                                  SvgPicture.asset(
                                    Assets.svg.arrowDown,
                                    width: 10.w,
                                    height: 10.w,
                                  )
                                else
                                  Image.asset(
                                    'assets/images/icon_arrow_up.png',
                                    width: 10.w,
                                    height: 10.w,
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
      bottom: 30.w,
      scrollController,
    );
  }
}
