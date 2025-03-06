import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/at_text.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/dialog_confirm.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/my_item_feed.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/board_list.dart';
import '../../../model/collect_page_model.dart';
import '../../../model/comment_list.dart';
import '../../../model/user.dart';
import '../../../utils/date_util.dart';
import '../../../utils/net_request.dart';
import '../../../widget/item_feed.dart';
import '../../../widget/no_data.dart';
import '../login_helper.dart';

class MyCommentItem extends StatelessWidget {
  const MyCommentItem({
    super.key,
    required this.item,
    this.userProfileInfo,
  });

  final CommentBean item;
  final UserProfile? userProfileInfo;

  @override
  Widget build(BuildContext context) {
    //当前数据是内容的评论的回复 -> 内容的评论的回复
    //1.回复没删, 评论删了, 资源删了或者禁用 -> 回复保留, 评论显示 该评论已经删除, 不做资源跳转; -> 显示html其中的内容是 资源已被删除
    //2.回复没删, 评论删了, 资源没删 -> 回复保留, 评论显示 该评论已经删除,不做资源跳转; -> 显示?????
    //3.回复没删, 评论没删, 资源没删 -> 回复保留, 评论显示, 资源跳转;
    //4.回复没删 评论没删,资源删了或者禁用; -> 回复保留, 评论显示, 资源不跳转;  -> 显示html其中的内容是 资源已被删除;
    //
    //当前数据是内容的评论
    //5.评论没删, 资源删了或者禁用 -> 显示html其中的内容是 资源已被删除 ->  resourceId=17815(内容id或者帖子id) resourceType="video" delType=5
    //6.评论没删, 资源没删 -> 评论保留, 资源跳转;  ->  resourceId=17815(内容id或者帖子id) resourceType="video" delType=6
    String? cover;
    String? content;
    String? title;
    if (item.relType == 'thread') {
      cover = item.thread?.files?.firstOrNull?.url;
      content = HtmlParseUtil.of.pureCommentText(item.comment);
      title = item.thread?.title;
    } else if (item.relType == 'content') {
      cover = item.content?.cover;
      title = item.content?.title;
      content = item.content?.description;
    } else if (item.relType == 'comment') {
      content =
          HtmlParseUtil.of.pureCommentText(item.parentComment?.contentStr);
      title = item.parentComment?.thread?.title;
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
      content = '该$typeName已被删除';
    }

    return GestureDetector(
      onTap: () {
        if (item.id == null) return;
        if (item.isDeleted) {
          ToastUtils.showToast('该$typeName已被删除');
          return;
        }
        final id = item.resourceId;
        if (id == null) return;
        if (item.resourceType == 'thread') {
          Get.toNamed(Routes.feedDetail, arguments: id);
        } else if (item.resourceType == 'article') {
          Get.toNamed(Routes.articleDetail, arguments: id);
        } else if (item.resourceType == 'book') {
          Get.toNamed(Routes.bookDetail, arguments: id);
        } else if (item.resourceType == 'video' ||
            item.resourceType == 'videoList') {
          Get.toNamed(Routes.videoDetail, arguments: {'id': id});
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BorderAvatar(
                  avatar: userProfileInfo?.avatar ?? '',
                  avatarSize: 20.w,
                  borderWidth: 0,
                ),
                SizedBox(width: 8.w),
                Text(
                  '评论了${typeName}:',
                  style: TextStyle(
                      color: '#333333'.hexColor.withOpacity(0.7),
                      fontSize: 12.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  content ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: '#333333'.hexColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  DateUtil.formatDate(item.createdAt!, format: 'yyyy.MM.dd'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: '#333333'.hexColor.withOpacity(0.8),
                  ),
                ),
                // Expanded(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [
                //       Text(
                //         userProfileInfo?.nickname ?? '',
                //         style: TextStyle(
                //           color: const Color(0xff2a2a2a),
                //           fontSize: 14.w,
                //           fontWeight: FontWeight.w500,
                //         ),
                //         maxLines: 1,
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //       SizedBox(height: 4.w),
                //       Row(
                //         children: [
                //           Expanded(
                //             child: item.isDeleted
                //                 ? Text(
                //                     content ?? '',
                //                     style: TextStyle(
                //                       color: '#333333'.hexColor,
                //                       fontSize: 12.sp,
                //                       fontWeight: FontWeight.w600,
                //                     ),
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                   )
                //                 : AtText(
                //                     text: content ?? '',
                //                     maxLines: 1,
                //                   ),
                //           ),
                //           if (item.createdAt != null)
                //             Padding(
                //               padding: EdgeInsets.only(left: 4.w),
                //               child: Text(
                //                 CommonUtils.timeFromNow(item.createdAt!),
                //                 style: TextStyle(
                //                   color: '#333333'.hexColor.withOpacity(0.5),
                //                   fontSize: 12.sp,
                //                 ),
                //               ),
                //             ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(width: 8.w),
                // if (cover?.isNotEmpty == true)
                //   Padding(
                //     padding: EdgeInsets.only(right: 10.w),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(4.r),
                //           child: CachedNetworkImage(
                //             fit: BoxFit.cover,
                //             imageUrl: cover ?? '',
                //             width: 74.w,
                //             height: 56.w,
                //             placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                //             errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                //           ),
                //         ),
                //         if (item.resourceType == 'videoList')
                //           Positioned(
                //             top: 0,
                //             right: 0,
                //             child: Container(
                //               padding: EdgeInsets.symmetric(horizontal: 2.w),
                //               decoration: BoxDecoration(
                //                 color: Colors.red,
                //                 borderRadius: BorderRadius.circular(4.r),
                //               ),
                //               child: Text(
                //                 '合集',
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 8.sp,
                //                 ),
                //               ),
                //             ),
                //           ),
                //       ],
                //     ),
                //   ),
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              margin: EdgeInsets.only(left: 10.w),
              child: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: '#333333'.hexColor.withOpacity(0.8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
