import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/color_style_util.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/dialog_common.dart';
import '../../../widget/no_data.dart';
import 'message_notice_controller.dart';

class Message_noticePage extends StatefulWidget {
  const Message_noticePage({Key? key}) : super(key: key);

  @override
  State<Message_noticePage> createState() => _Message_noticePageState();
}

class _Message_noticePageState extends State<Message_noticePage> {
  final Message_noticeController controller =
      Get.put(Message_noticeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '管方通知'),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return SlidableAutoCloseBehavior(
              child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: controller.refreshController,
                  onRefresh: controller.onRefresh,
                  onLoading: controller.onLoading,
                  child: ListView.builder(
                      itemBuilder: (c, i) {
                        return Slidable(
                            groupTag: '1-list',
                            //key: ValueKey('${collectList[i].id}'),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 42 / maxWidth,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) => CommonDialog(
                                        title: '删除收藏',
                                        content: '确定要删除这个收藏吗？',
                                        confirmText: '确认删除',
                                        onConfirm: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svg/icon_delete.svg',
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                              ],
                            ),
                            child: _buildListItemWidget(i));
                      },
                      itemCount: 5)),
            );
          },
        ));
  }

  @override
  void dispose() {
    Get.delete<Message_noticeController>();
    super.dispose();
  }

  // TODO: Build Widget
  Widget _buildListItemWidget(int index) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1.w, color: ColorStyle.c333333)),
            color: index == 0
                ? ColorStyle.c557BF6.withOpacity(0.1)
                : Colors.white),
        child: Row(
          children: [
            if (controller.isSystem)
              Image.asset(
                Assets.images.iconMessageSystemDf.path,
                width: 38.w,
                height: 38.w,
                fit: BoxFit.cover,
              )
            else
              CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: '',
                placeholder: (context, url) =>
                    Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                errorWidget: (context, url, error) =>
                    Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
              ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '官方通知',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorStyle.c333333),
                    ),
                    Text('1分钟前',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: ColorStyle.c333333.withOpacity(0.7)))
                  ],
                ),
                Expanded(
                    child: Text(
                  '亲爱的无敌铁头：恭喜您获得尊贵的德学院亲爱的无敌铁头：恭喜...',
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: index == 0
                          ? ColorStyle.c333333
                          : ColorStyle.c333333.withOpacity(0.7)),
                ))
              ],
            )
          ],
        ));
  }
}
