import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item_common_message.dart';

class MessageChildView extends StatefulWidget {
  final String type;

  const MessageChildView({super.key, required this.type});

  @override
  State<MessageChildView> createState() => MessageChildViewState();
}

class MessageChildViewState extends State<MessageChildView> {
  List<MessageBean> messages = [];
  final RefreshController _refreshController = RefreshController();
  bool loaded = false;
  int pageNum = 1;
  String strType = '';

  @override
  void initState() {
    super.initState();
    strType = widget.type;
    reqListData();
  }

  reqListData() {
    NetRequest().messageList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'type': strType}
    }, (data) {
      MessageList boardList = MessageList.fromJson(data);
      if (mounted) {
        final total = boardList.pager?.total ?? 0;
        if (pageNum == 1) {
          messages = boardList.list!;
          _refreshController.refreshCompleted();
          if (messages.length >= total) {
            _refreshController.loadNoData();
          } else {
            _refreshController.resetNoData();
          }
        } else {
          messages.addAll(boardList.list!);
          if (messages.length >= total) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        }
        loaded = true;
        setState(() {});
      }
    });
  }

  void refreshData(String type) {
    strType = type;
    _onRefresh();
  }

  void _onRefresh() async {
    pageNum = 1;
    reqListData();
  }

  void _onLoading() async {
    pageNum++;
    reqListData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height,
      ),
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
      child: content(),
    );
  }

  Widget content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: loaded && messages.isEmpty
          ? const Center(
              child: NoDataView(),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              itemBuilder: (c, i) => MessageCommonItem(
                item: messages[i],
                onTap: () => jumpPage(messages[i]),
              ),
              // itemExtent: 160.0,
              itemCount: messages.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 12.w),
                  color: const Color(0xffE7EDEE),
                  height: 1.w,
                );
              },
            ),
    );
  }

  jumpPage(MessageBean bean) {
    if (bean.jumpId == null) {
      return;
    }
    int id = bean.jumpId!;
    if (bean.jumpType == 'content') {
      if (bean.resourceType == 'book') {
        Get.toNamed(Routes.bookDetail, arguments: id);
      } else if (bean.resourceType == 'article') {
        Get.toNamed(Routes.articleDetail, arguments: id);
      } else if (bean.resourceType == 'video' || bean.resourceType == 'videoList') {
        Get.toNamed(Routes.videoDetail, arguments: {'id': id});
      }
    } else if (bean.jumpType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
    }
  }
}
