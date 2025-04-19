import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: CommonAppBar.arrowBack(context, title: '管方通知'),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 32.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                width: 38.w,
                height: 38.w,
                fit: BoxFit.cover,
                imageUrl: '',
                placeholder: (context, url) =>
                    Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                errorWidget: (context, url, error) =>
                    Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
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
                        borderRadius: BorderRadius.all(Radius.circular(8.w)),
                        border: Border.all(
                            width: 0.5.w,
                            color: ColorStyle.c333333.withOpacity(0.1))),
                    child: Text(
                      '想体验刺激烧脑的扑克对决吗？我们诚挚邀请您加入，开启精彩扑克之旅！​平台精心打造多种经典扑克玩法，无论您钟情德州扑克的策略博弈，还是热爱斗地主的欢乐竞技，这里都能满足您。别再犹豫，赶快下载游戏，与万千扑克爱好者一同畅享竞技乐趣，说不定下一个扑克大师是您！',
                      style:
                      TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
                    ),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    '2025.04.16 17:00',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ColorStyle.c333333.withOpacity(0.7)
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    Get.delete<MessageNoticeDetailController>();
    super.dispose();
  }
}
