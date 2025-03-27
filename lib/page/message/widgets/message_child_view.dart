import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../services/index.dart';
import '../../../utils/toast_utils.dart';
import '../message_screen.dart';
import 'item_common_message.dart';

part 'message_child_controller.dart';

class MessageChildView extends StatefulWidget {
  final MessageChildController controller;

  const MessageChildView({super.key, required this.controller});

  @override
  State<MessageChildView> createState() => MessageChildViewState();
}

class MessageChildViewState extends State<MessageChildView> {
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: widget.controller.items.isNotEmpty || !widget.controller.noMore,
      controller: widget.controller.refreshController,
      scrollController: widget.controller.scrollController,
      onRefresh: widget.controller._onRefresh,
      onLoading: widget.controller._onLoading,
      child: widget.controller.loaded && widget.controller.items.isEmpty
          ? const Center(
              child: NoDataView(),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              itemBuilder: (c, i) => MessageCommonItem(
                item: widget.controller.items[i],
                onTap: () => jumpPage(widget.controller.items[i]),
              ),
              // itemExtent: 160.0,
              itemCount: widget.controller.items.length,
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
