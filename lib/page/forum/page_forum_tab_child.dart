import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:group_button/group_button.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/constants.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/log_utils.dart';
import '../../view/forum/PostListView.dart';

class ForumTabChildPage extends StatefulWidget {
  int tabId;

  ForumTabChildPage({super.key, required this.tabId});

  @override
  State<ForumTabChildPage> createState() => ForumTabChildPageState();
}

class ForumTabChildPageState extends State<ForumTabChildPage> with AutomaticKeepAliveClientMixin {
  late int tabIdValue;
  late String filterValue = '';
  late int selectFilterIndex = 0;
  late Map<int, dynamic> filterMap = {};
  int pageNum = 1;
  int pageSize = 10;
  int pageId = 0;
  String boardSort = NetRequest.BOARD_SORT_TIME;
  List<BoardBean> boardPostList = [];
  var actionEventBus;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _listController = ScrollController();

  void _onRefresh() async {
    setState(() {
      pageNum = 1;
    });
    //通知外层板块tab拉取最新数据
    EventBusManager.eventBus
        .fire(EventBusAction.updateBoardTabData.eventBusTypeName);
    //当前列表刷新
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  void refreshData(int id,String order){
    setState(() {
      pageId = id;
      tabIdValue = id;
      boardSort = order;
    });
    _onRefresh();
  }

  @override
  void initState() {
    tabIdValue = pageId;//widget.tabId;
    super.initState();
    filterMap[0] = '时间最新';
    filterMap[1] = '回帖最多';
    filterMap[2] = '点赞最多';
    filterValue = filterMap[0].toString();

    reqListData();

    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.refreshForumList.eventBusTypeName) {
        print('========refreshForumList=====refreshForumList=============');
        if (mounted) {
          boardSort = NetRequest.BOARD_SORT_TIME;
          pageNum = 1;
          setState(() {
            filterValue = filterMap[0].toString();
            selectFilterIndex = getKeyByValue(filterMap[0].toString())!;
            reqListData();
            //由于tab设置了切换不重载，这个切换子类筛选的时候需要设置自动滚动到顶部
            _scrollToTop();
          });
        }
      }
    });
  }
  reqListData () {
    //tabIdValue = 0全部板块,不传boardId
    NetRequest().getThreadListByBoard(pageNum, pageSize,
        boardSort, tabIdValue == 0 ? '' : tabIdValue.toString(), '', '', (data) {
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

  @override
  void dispose() {
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 3.px,
      ),
      // getFilterConditionView(),
      SizedBox(
        height: 10.px,
      ),
      Expanded(child: boardPostList.isNotEmpty ? listView() : NoDataView())
    ]);
  }

  Widget getFilterConditionView() {
    return Row(
      children: [
        SizedBox(
          width: 5.px,
        ),
        Text('排序',
            style: TextStyle(
                color: sortTitleColor,
                fontSize: 14.px,
                fontWeight: FontWeight.w500)),
        SizedBox(
          width: 10.px,
        ),
        Expanded(child: groupRadio2()),
      ]);
  }

  ///列表数据
  Widget listView() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        controller:_listController,
        itemBuilder: (c, i)  {
          return PostListItemView(context, i, true, boardPostList[i]);
            // PostListItemView( itemIndex: i,
            //   isForumList: true,
            //   boardBean: boardPostList[i]);
        },
        itemCount: boardPostList.length,
      ),
    );
  }

  ///筛选条件
  // Widget groupRadio() {
  //   return GroupButton(
  //     isRadio: true,
  //     buttons: ["时间最新", "回帖最多", "点赞最多"],
  //     onSelected: (selected, date, context) {
  //       print('[forumLog]ddddddddddddddddddddd===>$selected');
  //       boardSort = selected == '时间最新'
  //           ? NetRequest.BOARD_SORT_TIME
  //             : selected == '回帖最多'
  //               ? NetRequest.BOARD_SORT_COMMENT
  //               : NetRequest.BOARD_SORT_LIKE;
  //       if (_isMounted) {
  //         setState(() {
  //           pageNum = 1;
  //           filterValue = selected;
  //           selectFilterIndex = getKeyByValue(selected)!;
  //           boardPostList.clear();
  //           reqListData();
  //           //由于tab设置了切换不重载，这个切换子类筛选的时候需要设置自动滚动到顶部
  //           _scrollToTop();
  //         });
  //       }
  //     },
  //     controller: GroupButtonController(selectedIndex: selectFilterIndex),
  //     //默认0位置选中
  //     options: GroupButtonOptions(
  //       selectedShadow: const [],
  //       selectedTextStyle: TextStyle(
  //         fontSize: 14.px,
  //         color: forumAppMainColor,
  //       ),
  //       selectedColor: AppTheme.color_1A008EFF, //选择背景
  //       unselectedShadow: const [],
  //       unselectedColor: AppTheme.color_80FFFFFF, //未选择背景
  //       unselectedTextStyle: TextStyle(
  //         fontSize: 13.px,
  //         color: tabTitleUnselectColor,
  //       ),
  //       selectedBorderColor: forumAppMainColor,
  //       unselectedBorderColor: AppTheme.color_80FFFFFF,
  //       borderRadius: BorderRadius.circular(100),
  //       spacing: 10,
  //       runSpacing: 10,
  //       groupingType: GroupingType.wrap,
  //       direction: Axis.horizontal,
  //       buttonHeight: 30.px,
  //       buttonWidth: 76.px,
  //       mainGroupAlignment: MainGroupAlignment.start,
  //       crossGroupAlignment: CrossGroupAlignment.start,
  //       groupRunAlignment: GroupRunAlignment.start,
  //       textAlign: TextAlign.center,
  //       textPadding: EdgeInsets.zero,
  //       alignment: Alignment.center,
  //       elevation: 0,
  //     ),
  //   );
  // }

  Widget groupRadio2() {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              filterValue = filterMap[0].toString();
              _selectFilter(filterValue);
            },
            child: selectFilterIndex == 0
                ? selectRadioStyleView('时间最新')
                : unselectRadioStyleView('时间最新')
          ),
          SizedBox(width: 10.px,),
          GestureDetector(
              onTap: () {
                filterValue = filterMap[1].toString();
                _selectFilter(filterValue);
              },
              child: selectFilterIndex == 1
                  ? selectRadioStyleView('回帖最多')
                  : unselectRadioStyleView('回帖最多')
          ),
          SizedBox(width: 10.px,),
          GestureDetector(
              onTap: () {
                filterValue = filterMap[2].toString();
                _selectFilter(filterValue);
              },
              child: selectFilterIndex == 2
                  ? selectRadioStyleView('点赞最多')
                  : unselectRadioStyleView('点赞最多')
          )
        ],
      ),
    );
  }

  _selectFilter(String selected) {
    print('[forumLog]ddddddddddddddddddddd===>$selected');
    boardSort = selected == '时间最新'
        ? NetRequest.BOARD_SORT_TIME
        : selected == '回帖最多'
        ? NetRequest.BOARD_SORT_COMMENT
        : NetRequest.BOARD_SORT_LIKE;
    if (mounted) {
      setState(() {
        pageNum = 1;
        filterValue = selected;
        selectFilterIndex = getKeyByValue(selected)!;
        boardPostList.clear();
        reqListData();
        //由于tab设置了切换不重载，这个切换子类筛选的时候需要设置自动滚动到顶部
        _scrollToTop();
      });
    }
  }

  Widget selectRadioStyleView (String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color:  AppTheme.color_1A008EFF, //选择背景
        border: Border.all(
          color: forumAppMainColor,
          width: 1.0, // 边框宽度为1像素
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(child: Text(text,style: TextStyle(
        fontSize: 14.px,
        color: forumAppMainColor,
      ),)),
    );
  }

  Widget unselectRadioStyleView (String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color:  AppTheme.color_80FFFFFF, //未选择背景
        border: Border.all(
          color: AppTheme.color_80FFFFFF,
          width: 1.0, // 边框宽度为1像素
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(child: Text(text,style: TextStyle(
        fontSize: 13.px,
        color: tabTitleUnselectColor,
      ),)),
    );
  }

  int? getKeyByValue(String selected) {
    for (var entry in filterMap.entries) {
      if (entry.value == selected) {
        return entry.key;
      }
    }
    return 0;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void _scrollToTop() {
    // 滚动到顶部的逻辑
    _listController.animateTo(
      0.0, // 滚动到顶部的偏移量
      duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
      curve: Curves.ease, // 滚动动画的曲线
    );
  }
}
