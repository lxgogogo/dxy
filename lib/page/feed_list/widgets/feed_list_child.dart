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
  final int tabId;

  const ForumTabChildPage({super.key, required this.tabId});

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

  void _onRefresh({bool showLoading = true, bool needJump = false}) async {
    //通知外层板块tab拉取最新数据
    EventBusManager.eventBus.fire(EventBusAction.updateBoardTabData.eventBusTypeName);
    pageNum = 1;
    reqListData(showLoading: showLoading, needJump: needJump);
  }

  void _onLoading() async {
    pageNum++;
    reqListData(showLoading: false);
  }

  void refreshData(int id, String order) {
    pageId = id;
    tabIdValue = id;
    boardSort = order;
    _onRefresh(needJump: true);
  }

  @override
  void initState() {
    tabIdValue = pageId; //widget.tabId;
    super.initState();

    reqListData();

    //接受通知刷新页面
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshForumList.eventBusTypeName) {
        boardSort = NetRequest.BOARD_SORT_TIME;
        pageNum = 1;
        reqListData();
      }
    });
  }

  reqListData({bool showLoading = true, bool needJump = false}) {
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
    NetRequest().getThreadListByBoard(params, showLoading: showLoading, (data) {
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
      if (needJump && _listController.hasClients) {
        _listController.jumpTo(0.0);
      }
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        boxShadow: [
          BoxShadow(
            color: '#b9d0e5'.hexColor.withOpacity(0.64),
            blurRadius: 2.r,
            offset: Offset(0, -1.w),
          ),
          BoxShadow(
            color: Colors.white,
            spreadRadius: 1.r,
            blurRadius: 2.r,
            offset: Offset(0, 1.w),
          ),
          BoxShadow(
            color: '#bfd2e2'.hexColor.withOpacity(0.81),
            blurRadius: 4.r,
            offset: Offset(0, 2.w),
          ),
          BoxShadow(
            color: '#f8fbff'.hexColor,
          ),
        ],
      ),
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
        controller: _refreshController,
        onRefresh: () => _onRefresh(showLoading: false),
        onLoading: _onLoading,
        child: boardPostList.isEmpty
            ? const NoDataView()
            : CustomScrollView(
                controller: _listController,
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
                        );
                      },
                      childCount: boardPostList.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
