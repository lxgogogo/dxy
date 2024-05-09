import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:group_button/group_button.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/constants.dart';
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

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
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
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    tabIdValue = widget.tabId;
    super.initState();
    filterMap[0] = '时间最新';
    filterMap[1] = '回帖最多';
    filterMap[2] = '点赞最多';
    filterValue = filterMap[0].toString();
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
        groupRadio(),
      ],
    );
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
        itemBuilder: (c, i) => PostListItemView( itemIndex: i, isForumList: true,),
        // itemExtent: 160.0,
        itemCount: items.length,
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
        setState(() {
          filterValue = selected;
          selectFilterIndex = getKeyByValue(selected)!;
        });
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
