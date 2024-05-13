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
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/constants.dart';
import '../../utils/log_utils.dart';
import '../../view/forum/PostListView.dart';

class ForumTabChildPage extends StatefulWidget {
  int tabId;

  ForumTabChildPage({super.key, required this.tabId});

  @override
  State<ForumTabChildPage> createState() => _ForumTabChildPageState();
}

class _ForumTabChildPageState extends State<ForumTabChildPage> {
  late int tabIdValue;
  late String filterValue = '';
  late int selectFilterIndex = 0;
  late Map<int, dynamic> filterMap = {};
  int pageNum = 1;
  int pageSize = 10;
  String boardSort = NetRequest.BOARD_SORT_TIME;
  List<BoardBean> boardPostList = [];
  bool _isMounted = false;


  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // boardPostList.add((boardPostList.length + 1));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    tabIdValue = widget.tabId;
    super.initState();
    _isMounted = true;
    filterMap[0] = '时间最新';
    filterMap[1] = '回帖最多';
    filterMap[2] = '点赞最多';
    filterValue = filterMap[0].toString();

    reqListData();
  }
  reqListData () {
    //tabIdValue = 0全部板块,不传boardId
    NetRequest().getThreadListByBoard(pageNum.toString(), pageSize.toString(),
        boardSort, tabIdValue == 0 ? '' : tabIdValue.toString(), '', '', (data) {
          BoardList boardList = BoardList.fromJson(data);
          if (_isMounted) {
            setState(() {
              boardPostList = boardList.list!;
            });
          }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 3.px,
      ),
      getFilterConditionView(),
      SizedBox(
        height: 10.px,
      ),
      Expanded(child: listView())
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
        Expanded(child: groupRadio()),
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
        itemBuilder: (c, i) =>
        boardPostList != null ?
            PostListItemView(itemIndex: i,
              isForumList: true,
              boardBean: boardPostList[i]) : null,
        itemCount: boardPostList.length,
      ),
    );
  }

  ///筛选条件
  Widget groupRadio() {
    return GroupButton(
      isRadio: true,
      buttons: ["时间最新", "回帖最多", "点赞最多"],
      onSelected: (selected, date, context) {
        print('[forumLog]ddddddddddddddddddddd===>$selected');
        boardSort = selected == '时间最新'
            ? NetRequest.BOARD_SORT_TIME
              : selected == '回帖最多'
                ? NetRequest.BOARD_SORT_COMMENT
                : NetRequest.BOARD_SORT_LIKE;
        if (_isMounted) {
          setState(() {
            filterValue = selected;
            selectFilterIndex = getKeyByValue(selected)!;
            reqListData();
          });
        }
      },
      controller: GroupButtonController(selectedIndex: selectFilterIndex),
      //默认0位置选中
      options: GroupButtonOptions(
        selectedShadow: const [],
        selectedTextStyle: TextStyle(
          fontSize: 14.px,
          color: forumAppMainColor,
        ),
        selectedColor: Colors.transparent,
        unselectedShadow: const [],
        unselectedColor: Colors.white,
        unselectedTextStyle: TextStyle(
          fontSize: 13.px,
          color: tabTitleUnselectColor,
        ),
        selectedBorderColor: forumAppMainColor,
        unselectedBorderColor: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        spacing: 10,
        runSpacing: 10,
        groupingType: GroupingType.wrap,
        direction: Axis.horizontal,
        buttonHeight: 30.px,
        buttonWidth: 76.px,
        mainGroupAlignment: MainGroupAlignment.start,
        crossGroupAlignment: CrossGroupAlignment.start,
        groupRunAlignment: GroupRunAlignment.start,
        textAlign: TextAlign.center,
        textPadding: EdgeInsets.zero,
        alignment: Alignment.center,
        elevation: 0,
      ),
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

// Widget foot() {
// return CustomFooter(buildContent);
//   (BuildContext context,LoadStatus mode){
//   Widget body ;
//   if(mode==LoadStatus.idle){
//     body =  Text("上拉加载");
//   }
//   else if(mode==LoadStatus.loading){
//     body =  CupertinoActivityIndicator();
//   }
//   else if(mode == LoadStatus.failed){
//     body = Text("加载失败！点击重试！");
//   }
//   else if(mode == LoadStatus.canLoading){
//     body = Text("松手,加载更多!");
//   }
//   else{
//     body = Text("没有更多数据了!");
//   }
//   return Container(
//     height: 55.0,
//     child: Center(child:body),
//   );
// },
// )
// }
}
