import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:intl/intl.dart';

class MessageCommonItem extends StatelessWidget {
  final MessageBean item;
  final VoidCallback? onTap;

  const MessageCommonItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String tipTitle = '@了我';
    String smallIcon = 'assets/images/aite.png';
    if (item.type == 'comment') {
      tipTitle = '评论了我';
      smallIcon = 'assets/images/comment_small.png';
    } else if (item.type == 'like') {
      tipTitle = '赞同了我';
      smallIcon = 'assets/images/zan.png';
    } else if (item.type == 'favorite') {
      tipTitle = '收藏了我的帖子';
      smallIcon = 'assets/images/collect_small.png';
    }
    String? title;
    String? content;
    String? cover;
    int? likeCount;
    int? favoriteCount;
    int? commentCount;
    if (item.jumpType == 'thread') {
      title = item.threadData?.title;
      content = item.threadData?.pureText;
      cover = item.threadData?.cover;
      likeCount = item.threadData?.likeCount;
      favoriteCount = item.threadData?.favoriteCount;
      commentCount = item.threadData?.commentCount;
    } else if (item.jumpType == 'content') {
      title = item.contentData?.title;
      content = item.contentData?.description;
      cover = item.contentData?.cover;
      likeCount = item.contentData?.likeCount;
      favoriteCount = item.contentData?.favoriteCount;
      commentCount = item.contentData?.commentCount;
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
                    smallIcon,
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
                  tipTitle,
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
                      if (item.description?.isNotEmpty == true)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.w),
                          child: HtmlWidget(
                            item.description ?? '',
                            textStyle: TextStyle(
                              color: const Color(0xff666666),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0x1A95A3C4),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            if (cover?.isNotEmpty == true)
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
                                      imageUrl: cover!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Image.asset(
                                        'assets/images/image_loading_def.png',
                                      ),
                                    ),
                                    if (item.resourceType == 'videoList')
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  if (item.contentUser?.nickname?.isNotEmpty == true)
                                    Text(
                                      item.contentUser!.nickname!,
                                      style: TextStyle(
                                        color: const Color(0xff2a2a2a),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  Text(
                                    item.content?.title ?? '',
                                    style: TextStyle(
                                      color: const Color(0xff666666),
                                      fontSize: 12.sp,
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
                                              '${likeCount ?? 0}',
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
                                              '${favoriteCount ?? 0}',
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
                                              '${commentCount ?? 0}',
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
