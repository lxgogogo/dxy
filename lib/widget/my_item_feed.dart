import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/count_widget.dart';

import '../gen/assets.gen.dart';
import '../model/board_list.dart';
import '../utils/date_util.dart';

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
        padding: EdgeInsets.symmetric(vertical: 16.w).copyWith(bottom: 12.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#F2F2F2'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title ?? '',
              style: TextStyle(
                color: ColorStyle.c333333,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.files?.isNotEmpty == true)
              SizedBox(height: 8.w)
            else
              SizedBox(height: 4.w),
            Row(
              children: [
                if (item.files?.isNotEmpty == true)
                  Container(
                    width: 88.w,
                    height: 49.w,
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
                          placeholder: (context, url) => Assets
                              .images.imageLoadingDef
                              .image(fit: BoxFit.fill),
                          errorWidget: (context, url, error) => Assets
                              .images.imageLoadingDef
                              .image(fit: BoxFit.fill),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pureText ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.color_666666,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*Text(
                            item.createdAt != null
                                ? DateUtil.formatDateAlias3(
                                item.createdAt?.millisecondsSinceEpoch ??
                                    0)
                                : '',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: AppTheme.color_999999),
                          ),*/
                          SizedBox(width: 100.w),
                          Row(
                            children: [
                              SimpleCountText(
                                count:
                                item.likeCount?.abbreviateNumber ?? '0',
                                desc: '点赞',
                              ),
                              const SimpleDot(),
                              SimpleCountText(
                                count: item.commentCount?.abbreviateNumber ??
                                    '0',
                                desc: '评论',
                              ),
                              const SimpleDot(),
                              SimpleCountText(
                                count: item.favoriteCount?.abbreviateNumber ??
                                    '0',
                                desc: '收藏',
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String? get showCover => item.files?.firstOrNull?.type == 'video'
      ? item.files?.firstOrNull?.posterUrl
      : item.files?.firstOrNull?.url;
}
