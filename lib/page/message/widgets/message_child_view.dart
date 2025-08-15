import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../services/index.dart';
import '../../../utils/dialog_util.dart';
import '../../../utils/track_utils.dart';
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
      onRefresh: widget.controller.onRefresh,
      onLoading: widget.controller.onLoading,
      child: widget.controller.loaded && widget.controller.items.isEmpty
          ? const Center(
              child: NoDataView(text: '这里暂时没有数据哦，快去交流互动吧',),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              itemBuilder: (c, i) => MessageCommonItem(
                item: widget.controller.items[i],
                onTap: TrackUtils.trackedTap(
                  onTap: () => widget.controller.jumpPage(widget.controller.items[i]),
                  userLogType: '114001',
                  params: widget.controller.items[i].jumpId,
                ),
              ),
              // itemExtent: 160.0,
              itemCount: widget.controller.items.length,
            ),
    ).scrollToTopWrapper(
      bottom: 30.w,
      widget.controller.scrollController,
    );
  }
}
