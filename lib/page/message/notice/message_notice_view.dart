import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/color_style_util.dart';
import '../../../utils/date_util.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/dialog_common.dart';
import '../../../widget/no_data.dart';
import 'message_notice_controller.dart';

class MessageNoticePage extends StatefulWidget {
  const MessageNoticePage({Key? key}) : super(key: key);

  @override
  State<MessageNoticePage> createState() => _MessageNoticePageState();
}

class _MessageNoticePageState extends State<MessageNoticePage> {
  final MessageNoticeController controller = Get.put(MessageNoticeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CommonAppBar.arrowBack(context,
            title: controller.isSystem.value ? '官方通知' : '用户私信'),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return SlidableAutoCloseBehavior(
                child: Obx(() => SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: controller.refreshController,
                    onRefresh: controller.onRefresh,
                    onLoading: controller.onLoading,
                    child: controller.dataList.isEmpty
                        ? const Center(child: NoDataView())
                        : ListView.builder(
                            itemBuilder: (c, i) {
                              return Slidable(
                                  groupTag: '1-list',
                                  key: ValueKey('${controller.dataList[i].id}'),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 60.w / maxWidth,
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            await showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (context) =>
                                                  CommonDialog(
                                                title: '删除信件',
                                                content:
                                                    '确定删除【${controller.dataList[i].sendUserName ?? ''}】发来的信件吗？',
                                                confirmText: '确认删除',
                                                onConfirm: () {
                                                  Navigator.of(context).pop();
                                                  controller.delete(
                                                      controller.dataList[i]);
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 60.w,
                                            color: Colors.red,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '删除',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ],
                                  ),
                                  child: _buildListItemWidget(i));
                            },
                            itemCount: controller.dataList.length))));
          },
        ));
  }

  @override
  void dispose() {
    Get.delete<MessageNoticeController>();
    super.dispose();
  }

  // TODO: Build Widget
  Widget _buildListItemWidget(int index) {
    final model = controller.dataList[index];
    String dateStr = '';
    if (model.createdAt != null) {
      dateStr = DateUtil.formatDateAlias3(
        model.createdAt!.millisecondsSinceEpoch,
        hasHM: true,
      );
    }
    return GestureDetector(
      onTap: () {
        model.isReader = 1;
        controller.dataList.refresh();
        Get.toNamed(Routes.noticeDetail, arguments: {
          'pageType': Get.arguments['pageType'],
          'id': model.id,
          'data': model.toJson()
        });
      },
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 16.w),
              decoration: BoxDecoration(
                  color: model.isReader == 0
                      ? ColorStyle.c557BF6.withOpacity(0.1)
                      : Colors.white),
              child: Row(
                children: [
                  model.isReader == 1
                      ? Opacity(
                          opacity: 0.7,
                          child: BorderAvatar(
                              avatarSize: 38.w,
                              avatar: model.sendUserHeadimg ?? ''))
                      : BorderAvatar(
                          avatarSize: 38.w,
                          avatar: model.sendUserHeadimg ?? ''),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 1.sw - 84.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                              model.sendUserName ?? '',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ColorStyle.c333333),
                            )),
                            Text(dateStr,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: ColorStyle.c333333.withOpacity(0.7)))
                          ],
                        ),
                      ),
                      SizedBox(height: 3.w),
                      SizedBox(
                          width: 1.sw - 84.w,
                          child: Text(
                              controller.htmlToPlainText(model.content ?? ''),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: index == 0
                                    ? ColorStyle.c333333
                                    : ColorStyle.c333333.withOpacity(0.7),
                                fontSize: 12.sp,
                              )))
                    ],
                  )
                ],
              )),
          Container(
              height: 1.w,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              color: model.isReader == 0
                  ? ColorStyle.c333333.withOpacity(0.15)
                  : ColorStyle.c333333.withOpacity(0.05))
        ],
      ),
    );
  }
}
