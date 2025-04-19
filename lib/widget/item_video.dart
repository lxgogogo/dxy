import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/duration_text.dart';
import 'package:intl/intl.dart';

import '../utils/date_util.dart';
import '../utils/log_utils.dart';

class VideoItem extends StatelessWidget {
  final ArticleBean item;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  const VideoItem({
    super.key,
    required this.item,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // case ：增加权限 跳转视频详情
        LogUtils.printAll("跳转视频详情====");
        Get.toNamed(
          Routes.videoDetail,
          arguments: {'id': item.id},
        );
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: 96.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: item.cover ?? '',
                    placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          height: 22.w,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          color: Colors.white.withOpacity(0.2),
                          child: Row(
                            children: [
                              Assets.images.iconPlay.image(
                                width: 10.w,
                                height: 10.w,
                              ),
                              Text(
                                '${item.viewCount?.abbreviateNumber ?? '0'}次播放',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                ),
                              ),
                              const Spacer(),
                              DurationText(
                                durationInSeconds: item.duration ?? 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (item.type == 'videoList')
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              '#557BF6'.hexColor,
                              '#84BCF9'.hexColor,
                            ],
                          ),
                          borderRadius: borderRadius ??
                              BorderRadius.only(
                                bottomLeft: Radius.circular(6.r),
                                topRight: Radius.circular(12.r),
                              ),
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
          ),
          Padding(
              padding: EdgeInsets.only(top: 6.w, bottom: 3.w),
              child: Row(
                children: [
                  if (item.featured == 1)
                    Container(
                      width: 28.w,
                      height: 18.w,
                      margin: EdgeInsets.only(right: 2.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.w)), color: ColorStyle.cFF650F),
                      child: Text(
                        '精选',
                        style: TextStyle(fontSize: 10.sp, color: Colors.white),
                      ),
                    ),
                  Expanded(
                      child: Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: '#333333'.hexColor,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              )),
          Row(
            children: [
              Text(
                item.createdAt != null ? DateFormat('yy.MM.dd').format(item.createdAt!) : '',
                style: TextStyle(
                  color: '#333333'.hexColor.withOpacity(0.3),
                  fontSize: 9.sp,
                ),
              ),
              const Spacer(),
              CountLike(
                count: item.likeCount.abbreviateNumber,
                usePlaceHolder: false,
              ),
              CountComment(
                count: item.commentCount.abbreviateNumber,
                usePlaceHolder: false,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class VideoHorizontalItem extends StatelessWidget {
  final ArticleBean item;
  final VoidCallback? onTap;

  const VideoHorizontalItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // case ：增加权限 跳转视频详情
        LogUtils.printAll("跳转视频详情====");
        Get.toNamed(
          Routes.videoDetail,
          arguments: {'id': item.id},
        );
        onTap?.call();
      },
      child: Container(
        height: 92.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: '#58A5FF'.hexColor.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 4.w),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 154.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: item.cover ?? '',
                    placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                  ),
                  if (item.type == 'videoList')
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              '#557BF6'.hexColor,
                              '#84BCF9'.hexColor,
                            ],
                          ),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.r)),
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.featured == 1)
                          Container(
                            width: 28.w,
                            height: 18.w,
                            margin: EdgeInsets.only(right: 2.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(4.w)), color: ColorStyle.cFF650F),
                            child: Text(
                              '精选',
                              style: TextStyle(fontSize: 10.sp, color: Colors.white),
                            ),
                          ),
                        Expanded(
                            child: Text(
                          item.title ?? '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.createdAt != null ? DateFormat('yy.MM.dd').format(item.createdAt!) : '',
                            style: TextStyle(
                              color: '#333333'.hexColor.withOpacity(0.3),
                              fontSize: 9.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CountLike(
                          count: item.likeCount.abbreviateNumber,
                          usePlaceHolder: false,
                        ),
                        CountComment(
                          count: item.commentCount.abbreviateNumber,
                          usePlaceHolder: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
