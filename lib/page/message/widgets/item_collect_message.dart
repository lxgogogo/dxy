import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../feed_detail/widgets/html_factory_builder.dart';
import '../../feed_detail/widgets/html_style_builder.dart';

class MessageCollectItem extends StatelessWidget {
  final MessageBean item;
  final VoidCallback? onTap;

  const MessageCollectItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? title;
    String? content;
    DateTime? createdAt;
    if (item.resourceType == 'thread') {
      title = item.threadData?.title;
      content = item.threadData?.content;
      createdAt = item.threadData?.createdAt;
    } else if (item.resourceType == 'content') {
      title = item.contentData?.title;
      content = item.contentData?.description;
      createdAt = item.contentData?.createdAt;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34.w,
            height: 34.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                BorderAvatar(avatar: item.fromUser?.avatar ?? ''),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/collect_small.png',
                    width: 12.w,
                    height: 12.w,
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.fromUser?.nickname ?? '',
                      style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      item.createdAt != null ? DateFormat('MM-dd HH:mm').format(item.createdAt!) : '',
                      style: TextStyle(
                        color: const Color(0xff9cacc9),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.w),
                Text(
                  '收藏了我的帖子',
                  style: TextStyle(
                    color: const Color(0xff666666),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.w),
                GestureDetector(
                  onTap: onTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0x1A95A3C4),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              title ?? '',
                              style: TextStyle(
                                color: const Color(0xff2a2a2a),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (content?.isNotEmpty == true)
                              Container(
                                constraints: BoxConstraints(maxHeight: 80.w),
                                margin: EdgeInsets.only(bottom: 8.w),
                                child: HtmlWidget(
                                  content ?? '',
                                  textStyle: TextStyle(
                                    color: const Color(0xff666666),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8.w),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/praise.png',
                                        width: 13.w,
                                        height: 13.w,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${item.content?.likeCount ?? 0}',
                                        style: TextStyle(
                                          color: const Color(0xff9CACC9),
                                          fontSize: 10.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/star.png',
                                        width: 13.w,
                                        height: 13.w,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${item.content?.favoriteCount ?? 0}',
                                        style: TextStyle(
                                          color: const Color(0xff9CACC9),
                                          fontSize: 10.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/comment.png',
                                        width: 13.w,
                                        height: 13.w,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${item.content?.commentCount ?? 0}',
                                        style: TextStyle(
                                          color: const Color(0xff9CACC9),
                                          fontSize: 10.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
