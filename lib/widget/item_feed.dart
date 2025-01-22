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
import 'feed_more_action.dart';

class FeedItem extends StatelessWidget {
  final BoardBean item;
  final bool isMyPost;
  final VoidCallback? onShield;
  final VoidCallback? onShieldUser;
  final VoidCallback? onReport;

  const FeedItem(
    this.item, {
    super.key,
    this.isMyPost = false,
    this.onShield,
    this.onShieldUser,
    this.onReport,
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
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 12.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#E6E6E6'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: const Color(0xff2a2a2a),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                if ((onShield != null || onShieldUser != null) && !UserStore.of.isMe(item.user?.id))
                  FeedMoreAction(
                    onShield: onShield,
                    onShieldUser: onShieldUser,
                    onReport: onReport,
                  ),
              ],
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                BorderAvatar(avatar: item.user?.avatar ?? '', avatarSize: 20.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        item.user?.nickname ?? '',
                        style: TextStyle(
                          color: '#2A2A2A'.hexColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.sign?.isNotEmpty == true) tagWidget(item.sign!),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.w),
            if (item.pureText?.isNotEmpty == true)
              Text(
                item.pureText ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: '#2A2A2A'.hexColor,
                ),
                softWrap: true,
              ),
            if (item.files?.isNotEmpty == true)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final itemWidth = (constraints.maxWidth - 12.w * 2) / 2.2;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(top: 8.w),
                    child: Row(
                      children: List.generate(
                        item.files?.length ?? 0,
                            (index) {
                          final fileItem = item.files![index];
                          return Container(
                            width: itemWidth,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
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
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 8.w),
            Row(
              children: [
                CountLike(count: item.likeCount?.abbreviateNumber ?? '0'),
                CountComment(count: item.commentCount?.abbreviateNumber ?? '0'),
                CountFavorite(count: item.favoriteCount?.abbreviateNumber ?? '0'),
                CountShare(count: item.shareCount?.abbreviateNumber ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tagWidget(List<String> sign) {
    String hex;
    String text;
    if (sign.contains('office')) {
      hex = '249CFC';
      text = '官方贴';
    } else if (sign.contains('boutique')) {
      hex = '#FF6700';
      text = '精品贴';
    } else if (sign.contains('newbie')) {
      hex = '#3CCB78';
      text = '新人贴';
    } else {
      return const SizedBox();
    }
    return Container(
      margin: EdgeInsets.only(left: 4.w),
      padding: EdgeInsets.fromLTRB(2.5.w, 1.w, 2.5.w, 1.w),
      decoration: BoxDecoration(
        color: hex.hexColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
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
