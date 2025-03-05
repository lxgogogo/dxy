import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/special_classic_footer.dart';
import 'item_common_message.dart';

class MessageChildView extends StatefulWidget {
  final String type;

  const MessageChildView({super.key, required this.type});

  @override
  State<MessageChildView> createState() => MessageChildViewState();
}

class MessageChildViewState extends State<MessageChildView> {
  bool loaded = false;
  int pageNum = 1;
  int pageSize = 20;
  String strType = '';

  List<MessageBean> messages = [];
  final RefreshController _refreshController = RefreshController();
  final ScrollController _listController = ScrollController();

  StreamSubscription? eventSubscription;

  void _onRefresh() async {
    pageNum = 1;
    reqListData(showLoading: false);
  }

  void _onLoading() async {
    pageNum++;
    reqListData(showLoading: false);
  }

  void refreshData(String type) {
    if (_listController.hasClients) {
      _listController.jumpTo(0.0);
    }
    strType = type;
    pageNum = 1;
    reqListData();
  }

  @override
  void initState() {
    strType = widget.type;
    super.initState();
    reqListData();
    eventSubscription = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      reqListData(showLoading: false);
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    _listController.dispose();
    super.dispose();
  }

  reqListData({bool showLoading = true}) {
    NetRequest().messageList(
      {
        'pageNum': pageNum,
        'pageSize': pageSize,
        'filters': {
          'type': strType,
        },
      },
      showLoading: false,
      (data) {
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height,
      ),
      child: content(),
    );
  }

  Widget content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: const SpecialClassicFooter(),
      controller: _refreshController,
      scrollController: _listController,
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
                  margin: EdgeInsets.symmetric(vertical: 12.w,horizontal: 16.w),
                  color: '#000000'.hexColor.withOpacity(0.05),
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
