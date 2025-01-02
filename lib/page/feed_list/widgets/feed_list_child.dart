import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/eventbus/EventBusAction.dart';
import '../../../utils/eventbus/EventBusManager.dart';
import '../../../widget/item_feed.dart';

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
    //tabIdValue = 0全部板块,不传boardId
    NetRequest().getThreadListByBoard(
        pageNum, pageSize, boardSort, tabIdValue == 0 ? '' : tabIdValue.toString(), '', '', (data) {
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

  Future<void> onShied(int id) async {
    final success = await NetRequest().shieldFeed(id);
    if (success) {
      pageNum = 1;
      reqListData();
    }
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
                return FeedItem(boardPostList[i], onShield: () {
                  if (boardPostList[i].id != null) {
                    UserStore.of.checkLogin(() {
                      onShied.call(boardPostList[i].id!);
                    });
                  }
                });
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
