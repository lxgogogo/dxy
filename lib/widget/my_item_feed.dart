import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/count_widget.dart';

import '../gen/assets.gen.dart';
import '../model/board_list.dart';

class MyFeedItem extends StatelessWidget {
  final BoardBean item;

  const MyFeedItem(
    this.item, {
    super.key,
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
        padding: EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#F2F2F2'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title ?? '',
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.w),
            SizedBox(
              height: 66.w,
              child: Row(
                children: [
                  if (item.files?.isNotEmpty == true)
                    Container(
                      width: 88.w,
                      height: 66.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: showCover ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                            errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                          ),
                          if (item.files!.first.type == 'video')
                            Center(
                              child: Assets.images.playBtn.image(
                                width: 24.w,
                                height: 24.w,
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.pureText ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: '#333333'.hexColor.withOpacity(0.7),
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            SimpleCountText(
                              count: item.likeCount?.abbreviateNumber ?? '0',
                              desc: '点赞',
                            ),
                            const SimpleDot(),
                            SimpleCountText(
                              count: item.commentCount?.abbreviateNumber ?? '0',
                              desc: '评论',
                            ),
                            const SimpleDot(),
                            SimpleCountText(
                              count: item.favoriteCount?.abbreviateNumber ?? '0',
                              desc: '收藏',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? get showCover =>
      item.files?.firstOrNull?.type == 'video' ? item.files?.firstOrNull?.posterUrl : item.files?.firstOrNull?.url;
}
