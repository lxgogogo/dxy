import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:group_button/group_button.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/constants.dart';

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
          width: 15.px,
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
        itemBuilder: (c, i) => Card(child: listDataItem(i)),
        // itemExtent: 160.0,
        itemCount: items.length,
      ),
    );
  }

  Widget listDataItem(int index) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '这是一个标题这是一个标题这是一个标题这是一个标题这是一个标题这是一个标题',
                maxLines: 1,
                textAlign: TextAlign.start,
                style: AppTheme.text3B5078Size17,
              ),
              SizedBox(
                height: 8.px,
              ),
              Row(
                children: [
                  Container(
                    child: ClipOval(
                      child: Image.network(
                        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.px,
                  ),
                  Text(
                    '这个昵称',
                    style: AppTheme.text666666Size13,
                  )
                ],
              ),
              SizedBox(
                height: 5.px,
              ),
              Text(
                '很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text666666Size14,
                softWrap: true,
              ),
              Visibility(
                  child: mediaContent(index),
                  visible: index == 2 ? false : true),
              SizedBox(
                height: 5.px,
              ),
              Text(
                '121 赞同 · 78 评论 · 90 收藏',
                style: AppTheme.text999999Size12,
                maxLines: 1,
              )
            ]));
  }

  Widget mediaContent(int index) {
    if (index == 0) {
      return singleImageView(
          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp');
    } else if (index == 1) {
      //视频
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
        child: Center(
            child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 335,
              height: 188,
              child: Image.network(
                'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                width: 335,
                height: 188,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/images/play_btn.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        )),
      );
    } else if (index == 2) {
      //不显示
      return Image.network(
        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
        width: 335,
        height: 188,
      );
    } else if (index == 3) {
      //2张
      int num = 2;
      double screenWidth = MediaQuery.of(context).size.width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 10) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
        ],
      );
    }else if (index == 4) {
      //大于等于3张
      int num = 3;
      double screenWidth = MediaQuery.of(context).size.width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 10) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
        ],
      );
    } else {
      return singleImageView(
          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp');
    }
  }

  Widget singleImageView(String imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl,
          width: 130,
          height: 90,
          fit: BoxFit.fill,
        ));
  }

  Widget multipleImageView(double imageWidth,String imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl,
          width: imageWidth,
          height: 111,
          fit: BoxFit.cover,
        ));
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
