import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/item_comment.dart';

import '../gen/assets.gen.dart';
import '../model/board_list.dart';
import '../utils/date_util.dart';
import 'feed_more_action.dart';

class FeedItem extends StatelessWidget {
  final BoardBean item;
  final bool isMyPost;
  final VoidCallback? onShield;
  final VoidCallback? onShieldUser;
  final VoidCallback? onReport;
  final VoidCallback? onTap;

  const FeedItem(
    this.item, {
    super.key,
    this.isMyPost = false,
    this.onShield,
    this.onShieldUser,
    this.onReport,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.relType != null && item.relType!.isNotEmpty) {
          if (item.relType == 'content') {
            Get.toNamed(Routes.articleDetail, arguments: item.id ?? 0);
          } else if (item.relType == 'comment') {}
        } else {
          Get.toNamed(Routes.feedDetail, arguments: item.id ?? 0);
        }
        onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.w),
        padding: EdgeInsets.only(bottom: 12.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#333333'.hexColor.withOpacity(0.05))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (item.sign?.isNotEmpty == true) tagWidget(item.sign!),
                Expanded(
                  child: Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: '#333333'.hexColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                if ((onShield != null || onShieldUser != null) && !UserStore.of.isMe(item.user?.id))
                  FeedMoreAction(
                    actions: {'屏蔽该内容': onShield, '屏蔽该用户': onShieldUser, '举报该内容': onReport},
                  ),
              ],
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                BorderAvatar(avatar: item.user?.avatar ?? '', avatarSize: 20.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    item.user?.nickname ?? '',
                    style: TextStyle(
                      color: '#666666'.hexColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            if (item.pureText?.isNotEmpty == true)
              Text(
                item.pureText ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: '#666666'.hexColor,
                ),
                softWrap: true,
              ),
            if (item.files?.isNotEmpty == true)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(top: 8.w),
                child: Row(
                  children: List.generate(
                    item.files?.length ?? 0,
                    (index) {
                      final fileItem = item.files![index];
                      return Container(
                        width: 160.w,
                        height: 90.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: getFilesUrl(fileItem),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                              errorWidget: (context, url, error) =>
                                  Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                            ),
                            if (fileItem.type == 'video')
                              Center(
                                child: Assets.images.playBtn.image(
                                  width: 32.w,
                                  height: 32.w,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 8.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.createdAt != null)
                  Text(
                    '${DateUtil.formatDateAlias3(item.createdAt?.millisecondsSinceEpoch ?? 0)}发布',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: '#999999'.hexColor,
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  [
                    '${item.likeCount?.abbreviateNumber ?? '0'}点赞',
                    '${item.commentCount?.abbreviateNumber ?? '0'}评论',
                    '${item.favoriteCount?.abbreviateNumber ?? '0'}收藏',
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: '#999999'.hexColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget tagWidget(List<String> sign) {
    String hex;
    String text;
    if (sign.contains('office')) {
      hex = '557BF6';
      text = '官方贴';
    } else if (sign.contains('boutique')) {
      hex = '#F69555';
      text = '精品贴';
    } else if (sign.contains('newbie')) {
      hex = '36CA76';
      text = '新人贴';
    } else {
      return const SizedBox();
    }
    return Container(
      height: 18.w,
      margin: EdgeInsets.only(right: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: hex.hexColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  String getFilesUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
      return uploadFile.posterUrl!;
    }
    return uploadFile.url ?? '';
  }
}
