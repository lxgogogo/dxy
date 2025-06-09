import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/date_util.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:html/dom.dart' as dom;

import '../../../widget/common_app_bar.dart';
import '../../feed_detail/widgets/html_factory_builder.dart';
import '../../feed_detail/widgets/html_style_builder.dart';
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
    return Obx(() {
      String dateStr = '';
      if (controller.detailData.value.createdAt != null) {
        dateStr = DateUtil.formatDateAlias3(
          controller.detailData.value.createdAt!.millisecondsSinceEpoch,
          hasHM: true,
        );
      }
      return Scaffold(
        appBar: CommonAppBar.arrowBack(context,
            title: controller.detailData.value.sendUserName ?? ''),
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
                        borderRadius: BorderRadius.all(Radius.circular(19.w))),
                    child: BorderAvatar(
                      avatarSize: 38.w,
                        avatar: controller.detailData.value.sendUserHeadimg ?? '')
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: rightWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SelectionArea(
                            child: Container(
                                width: rightWidth,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8.w)),
                                    border: Border.all(
                                        width: 0.5.w,
                                        color: ColorStyle.c333333.withOpacity(0.1))),
                                child: HtmlWidget(
                                  controller.detailData.value.content  ?? '',
                                  customStylesBuilder: htmlCustomStyles,
                                  factoryBuilder: () => HtmlFactoryBuilder(
                                    context,
                                    content: controller.detailData.value.content  ?? '',
                                  ),
                                  customWidgetBuilder: (dom.Element element) {
                                    if (element.localName == 'table') {
                                      return const SizedBox();
                                    }
                                    return null;
                                  },
                                  onTapUrl: (String url) async {
                                    return launchUrlString(url, mode: LaunchMode.externalApplication);
                                  },
                                )
                            )
                        ),
                        SizedBox(height: 5.w),
                        Text(
                          dateStr,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: ColorStyle.c333333.withOpacity(0.7)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
      );
    });
  }

  @override
  void dispose() {
    Get.delete<MessageNoticeDetailController>();
    super.dispose();
  }
}
