import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:intl/intl.dart';

import '../../../utils/date_util.dart';
import '../../../utils/html_parse_util.dart';
import '../../../widget/at_text.dart';

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
    String? tipTitle;
    String? smallIcon;
    if (item.type == 'at') {
      var resourceType = '';
      if (item.resourceType == 'book') {
        resourceType = '书籍';
      } else if (item.resourceType == 'video') {
        resourceType = '视频';
      } else if (item.resourceType == 'videoList') {
        resourceType = '视频合集';
      } else if(item.resourceType=='article'){
        resourceType = '教程';
      }
      else {
        resourceType = item.itemType == 'comment' ? '评论中' : '帖子中';
      }
      tipTitle = '在$resourceType@了你';

      smallIcon = 'assets/images/aite.png';
    } else if (item.type == 'comment') {
      tipTitle = item.itemType == 'comment' ? '回复了你的评论' : '评论了你的贴子';
      smallIcon = 'assets/images/comment_small.png';
    } else if (item.type == 'like') {
      tipTitle = item.itemType == 'comment' ? '点赞了你的评论' : '点赞了你的帖子';
      smallIcon = 'assets/images/zan.png';
    } else if (item.type == 'favorite') {
      tipTitle = '收藏了你的帖子';
      smallIcon = 'assets/images/collect_small.png';
    }

    String? title;
    String? cover;
    int? likeCount;
    int? favoriteCount;
    int? commentCount;
    if (item.jumpType == 'thread') {
      title = item.threadData?.title;
      if (item.threadData?.cover?.isNotEmpty == true) {
        cover = item.threadData?.cover;
      } else if (item.threadData?.files?.firstOrNull?.url?.isNotEmpty == true) {
        cover = item.threadData?.files?.firstOrNull?.url;
      }
      likeCount = item.threadData?.likeCount;
      favoriteCount = item.threadData?.favoriteCount;
      commentCount = item.threadData?.commentCount;
    } else if (item.jumpType == 'content') {
      title = item.contentData?.title;
      cover = item.contentData?.cover;
      likeCount = item.contentData?.likeCount;
      favoriteCount = item.contentData?.favoriteCount;
      commentCount = item.contentData?.commentCount;
    }

    String typeName = '';

      if (item.resourceType == 'thread') {
        typeName = '帖子';
      } else if (item.resourceType == 'article') {
        typeName = '教程';
      } else if (item.resourceType == 'video') {
        typeName = '视频';
      } else if (item.resourceType == 'videoList') {
        typeName = '视频合集';
      } else if (item.resourceType == 'book') {
        typeName = '书籍';
      }else{
        typeName = '资源';
      }

    Log.d('resourceType: ${item.resourceType} ${item.delType}');
    if (item.isDeleted) {
      title = '该$typeName已被删除';
    }
    final isFavorite = item.type == 'favorite';
    return GestureDetector(
      onTap: () {
        if (item.isDeleted) {
          ToastUtils.showToast('该$typeName已被删除');
          return;
        }
        onTap?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36.w,
              height: 36.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BorderAvatar(avatar: item.fromUser?.avatar ?? ''),
                  // if (smallIcon?.isNotEmpty == true)
                  //   Positioned(
                  //     right: 0,
                  //     bottom: 0,
                  //     child: Image.asset(
                  //       smallIcon!,
                  //       width: 12.w,
                  //       height: 12.w,
                  //     ),
                  //   )
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.fromUser?.nickname ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (isFavorite)
                        const SizedBox()
                      else
                        Text(
                          item.createdAt != null
                              ? DateUtil.formatDateAlias3(
                                  item.createdAt!.millisecondsSinceEpoch)
                              : '',
                          style: TextStyle(
                            color: '#333333'.hexColor.withOpacity(0.7),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Row(
                    children: [
                      Text(
                        tipTitle ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (isFavorite)
                        Text(
                          item.createdAt != null
                              ? DateUtil.formatDateAlias3(
                                  item.createdAt!.millisecondsSinceEpoch)
                              : '',
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // if (item.description?.isNotEmpty == true)
                              //   AtText(text: HtmlParseUtil.of.pureCommentText(item.description)),
                              Text(
                                title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: '##333333'.hexColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  //  SizedBox(height: 8.w),
                ],
              ),
            ),
            // if(isFavorite)
            // Container(
            //   width: 70,
            //   height: 28,
            //   decoration: ShapeDecoration(
            //     shape: RoundedRectangleBorder(
            //       side: const BorderSide(width: 1, color: Color(0xFF557BF6)),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //   ),
            //   child:const Center(
            //     child: Text(
            //       '回关',
            //       style: TextStyle(
            //         color: Color(0xFF557BF6),
            //         fontSize: 12,
            //         fontFamily: 'PingFang SC',
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ) ,
            // )
          ],
        ),
      ),
    );
  }
}
