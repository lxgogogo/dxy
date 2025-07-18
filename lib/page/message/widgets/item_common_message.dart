import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/widget/item_comment.dart';

import '../../../utils/date_util.dart';

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
      } else if (item.resourceType == 'tool') {
        resourceType = '工具';
      } else if (item.resourceType == 'video') {
        resourceType = '视频';
      } else if (item.resourceType == 'videoList') {
        resourceType = '视频合集';
      } else if (item.resourceType == 'article') {
        resourceType = '教程';
      } else {
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
    } else if (item.resourceType == 'tool') {
      typeName = '工具';
    } else {
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
          DialogUtil.showToast('该$typeName已被删除');
          return;
        }
        onTap?.call();
      },
      child: Container(
        alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w).copyWith(bottom: 0),
          decoration: BoxDecoration(
            color: item.readStatus == 1 ? Colors.white : '#557BF6'.hexColor.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 42.w,
                    height: 42.w,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BorderAvatar(avatar: item.fromUser?.avatar ?? '', avatarSize: 42.w),
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
                          children: [
                            Expanded(
                              child: Text(
                                item.fromUser?.nickname ?? '',
                                style: TextStyle(
                                  color: ColorStyle.c333333,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              item.createdAt != null
                                  ? DateUtil.formatDateAlias3(item.createdAt?.millisecondsSinceEpoch ?? 0)
                                  : '',
                              style: TextStyle(
                                color: AppTheme.color_999999,
                                fontSize: 10.sp,
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
                                color: AppTheme.color_666666,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ColorStyle.c333333,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600
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
                  //         fontSize: 12.sp,
                  //         fontFamily: 'PingFang SC',
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ) ,
                  // )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 12.w),
                height: 1.w,
                color: Colors.black.withOpacity(0.05),
              )
            ],
          )
      )
    );
  }
}
