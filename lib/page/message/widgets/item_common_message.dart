import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:intl/intl.dart';

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
      tipTitle = '@了我';
      smallIcon = 'assets/images/aite.png';
    } else if (item.type == 'comment') {
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
    if (item.delType == 1 || item.delType == 2) {
      typeName = '评论';
    } else if (item.delType == 4) {
      typeName = '资源';
    } else {
      if (item.resourceType == 'thread') {
        typeName = '帖子';
      } else if (item.resourceType == 'article') {
        typeName = '资讯';
      } else if (item.resourceType == 'video') {
        typeName = '视频';
      } else if (item.resourceType == 'videoList') {
        typeName = '视频合集';
      } else if (item.resourceType == 'book') {
        typeName = '书籍';
      }
    }

    if (item.isDeleted) {
      title = '该$typeName已被删除';
    }

    return Padding(
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
                if (smallIcon?.isNotEmpty == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      smallIcon!,
                      width: 12.w,
                      height: 12.w,
                    ),
                  )
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
                  tipTitle ?? '',
                  style: TextStyle(
                    color: const Color(0xff666666),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.w),
                GestureDetector(
                  onTap: () {
                    if (item.isDeleted) {
                      ToastUtils.showToast('该$typeName已被删除');
                      return;
                    }
                    onTap?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item.description?.isNotEmpty == true)
                        AtText(text: HtmlParseUtil.of.pureCommentText(item.description)),
                      Container(
                        margin: EdgeInsets.only(top: 10.w),
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(color: Color(0x1a95A3C4)),
                        child: item.isDeleted
                            ? Text(
                                title ?? '',
                                style: TextStyle(
                                  color: const Color(0xff2a2a2a),
                                  fontSize: 12.sp,
                                ),
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      if (cover?.isNotEmpty == true)
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.w),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4.r),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: cover!,
                                                  width: 24.w,
                                                  height: 24.w,
                                                  placeholder: (context, url) => Image.asset(
                                                    'assets/images/image_loading_def.png',
                                                  ),
                                                  errorWidget: (context, url, error) =>
                                                      Image.asset('assets/images/image_loading_def.png'),
                                                ),
                                              ),
                                              if (item.resourceType == 'videoList')
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(4.r),
                                                    ),
                                                    child: Text(
                                                      '合集',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            AtText(
                                              text: HtmlParseUtil.of.pureCommentText(title),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CountLike(count: likeCount?.abbreviateNumber ?? '0'),
                                      ),
                                      Expanded(
                                        child: CountFavorite(count: favoriteCount?.abbreviateNumber ?? '0'),
                                      ),
                                      Expanded(
                                        child: CountComment(count: commentCount?.abbreviateNumber ?? '0'),
                                      ),
                                    ],
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
