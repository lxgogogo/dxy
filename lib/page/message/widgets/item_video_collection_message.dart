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

class MessageVideoCollectionItem extends StatelessWidget {
  final MessageBean item;
  final VoidCallback? onTap;

  const MessageVideoCollectionItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                item.content?.title ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 14.w,
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                item.createdAt != null ? DateFormat('MM-dd HH:mm').format(item!.createdAt!) : '',
                style: TextStyle(
                  color: const Color(0xff9CACC9),
                  fontSize: 12.w,
                ),
              ),
            ],
          ),
          Text(
            '更新了新的视频',
            style: TextStyle(
              color: const Color(0xff9CACC9),
              fontSize: 12.w,
            ),
          ),
          SizedBox(height: 4.w),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0x1A95A3C4),
                borderRadius: BorderRadius.all(Radius.circular(4.w)),
              ),
              child: Row(
                children: [
                  if (item.contentData?.cover?.isNotEmpty == true)
                    Container(
                      width: 48.w,
                      height: 48.w,
                      margin: EdgeInsets.only(right: 15.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.w)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: item.contentData!.cover!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              'assets/images/image_loading_def.png',
                            ),
                          ),
                          Positioned(
                            top: 2.w,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                '合集',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.contentData?.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            color: const Color(0xff2a2a2a),
                            fontSize: 14.sp,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
