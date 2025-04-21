import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../../widget/common_app_bar.dart';
import 'message_notice_detail_controller.dart';

class MessageNoticeDetailPage extends StatefulWidget {
  const MessageNoticeDetailPage({Key? key}) : super(key: key);

  @override
  State<MessageNoticeDetailPage> createState() =>
      _MessageNoticeDetailPageState();
}

class _MessageNoticeDetailPageState extends State<MessageNoticeDetailPage> {
  final MessageNoticeDetailController controller =
      Get.put(MessageNoticeDetailController());

  @override
  Widget build(BuildContext context) {
    double rightWidth = 1.sw - 58.w - 38.w;
    return Obx(() => Scaffold(
          appBar: CommonAppBar.arrowBack(context,
              title: controller.isSystem.value ? '官方通知' : '用户私信'),
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 32.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(19.w))),
                  child: CachedNetworkImage(
                    width: 38.w,
                    height: 38.w,
                    fit: BoxFit.cover,
                    imageUrl: controller.detailData.value.sendUserHeadimg ?? '',
                    placeholder: (context, url) => Assets
                        .images.imageLoadingDef
                        .image(fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Assets
                        .images.imageLoadingDef
                        .image(fit: BoxFit.fill),
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: rightWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: rightWidth,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.w)),
                            border: Border.all(
                                width: 0.5.w,
                                color: ColorStyle.c333333.withOpacity(0.1))),
                        child: DefaultTextStyle(
                            style: TextStyle(
                              color: ColorStyle.c333333,
                              fontSize: 12.sp,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: Html(
                              data: controller.detailData.value.content ?? "",
                              shrinkWrap: true,
                            ))
                      ),
                      SizedBox(height: 5.w),
                      Text(
                        controller.detailData.value.createdAt ?? '',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: ColorStyle.c333333.withOpacity(0.7)),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
        ));
  }

  @override
  void dispose() {
    Get.delete<MessageNoticeDetailController>();
    super.dispose();
  }
}
