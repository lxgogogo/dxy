import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../services/index.dart';
import '../../../stores/config_store.dart';
import '../../../utils/eventbus/EventBusAction.dart';
import '../../../utils/eventbus/EventBusManager.dart';
import '../../../utils/log_util.dart';
import '../../../utils/toast_utils.dart';
import '../../../widget/item_feed.dart';
import '../../../widget/report_sheet.dart';

class ForumTabChildPage extends StatefulWidget {
  int tabId;

  ForumTabChildPage({super.key, required this.tabId});

  @override
  State<ForumTabChildPage> createState() => ForumTabChildPageState();
}

class ForumTabChildPageState extends State<ForumTabChildPage> with AutomaticKeepAliveClientMixin {
  late int tabIdValue;

  int pageNum = 1;
  int pageSize = 10;
  int pageId = 0;
  String boardSort = NetRequest.BOARD_SORT_TIME;
  List<BoardBean> boardPostList = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _listController = ScrollController();

  void _onRefresh() async {
    setState(() {
      pageNum = 1;
    });
    //通知外层板块tab拉取最新数据
    EventBusManager.eventBus.fire(EventBusAction.updateBoardTabData.eventBusTypeName);
    //当前列表刷新
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  void refreshData(int id, String order) {
    setState(() {
      pageId = id;
      tabIdValue = id;
      boardSort = order;
    });
    _onRefresh();
  }

  @override
  void initState() {
    tabIdValue = pageId; //widget.tabId;
    super.initState();

    reqListData();

    //接受通知刷新页面
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshForumList.eventBusTypeName) {
        if (mounted) {
          boardSort = NetRequest.BOARD_SORT_TIME;
          pageNum = 1;
          setState(() {
            reqListData();
            _scrollToTop();
          });
        }
      }
    });
  }

  reqListData() {
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
    NetRequest().getThreadListByBoard(params, (data) {
      BoardList boardList = BoardList.fromJson(data);
      if (mounted) {
        setState(() {
          if (pageNum == 1) {
            boardPostList = boardList.list!;
          } else {
            boardPostList.addAll(boardList.list!);
          }
        });
      }
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
    });
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
              ToastUtils.showToast('举报成功，我们将会在24小时内受理');
            }
          } finally {
            Get.back();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: boardPostList.isNotEmpty
          ? ListView.builder(
              controller: _listController,
              itemBuilder: (c, i) {
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
                );
              },
              itemCount: boardPostList.length,
            )
          : const NoDataView(),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _scrollToTop() {
    _listController.animateTo(
      0.0, // 滚动到顶部的偏移量
      duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
      curve: Curves.ease, // 滚动动画的曲线
    );
  }
}
