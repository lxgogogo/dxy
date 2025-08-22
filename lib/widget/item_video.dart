import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

import '../utils/log_utils.dart';
import 'common_image.dart';

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
        Get.toNamed(
          Routes.videoDetail,
          arguments: {'id': item.id},
        );
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 166 / 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CommonImage.net(
                    imageUrl: item.cover ?? '',
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 22.w,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0.0572,
                            0.6034,
                            0.9448,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                            Colors.black,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            Assets.svg.iconPlayRect,
                            width: 12.w,
                            height: 12.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '${item.viewCount?.abbreviateNumber ?? '0'}次播放',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                          DurationText(
                            durationInSeconds: item.duration ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.type == 'videoList')
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 22.w,
                        padding: EdgeInsets.symmetric(horizontal: 7.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              '#557BF6'.hexColor,
                              '#84BCF9'.hexColor,
                            ],
                          ),
                          borderRadius: borderRadius ??
                              BorderRadius.only(
                                topRight: Radius.circular(12.r),
                                bottomLeft: Radius.circular(12.r),
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
              padding: EdgeInsets.only(top: 7.w, bottom: 5.w),
              child: Row(
                children: [
                  if (item.featured == 1)
                    Container(
                      height: 18.w,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      margin: EdgeInsets.only(right: 4.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.r)), color: ColorStyle.cFF650F),
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              )),
          Row(
            children: [
              Text(
                item.createdAt != null ? DateFormat('yyyy.MM.dd').format(item.createdAt!) : '',
                style: TextStyle(
                  color: '#999999'.hexColor,
                  fontSize: 10.sp,
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
          color: Colors.white.withOpacity(0.7),
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
              width: 140.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: item.cover ?? '',
                    placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      Assets.svg.iconVideoPlay,
                      width: 28.w,
                      height: 28.w,
                    ),
                  ),
                  if (item.type == 'videoList')
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 22.w,
                        padding: EdgeInsets.symmetric(horizontal: 7.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              '#557BF6'.hexColor,
                              '#84BCF9'.hexColor,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 12.w, 8.w, 8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.featured == 1)
                          Container(
                            height: 18.w,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            margin: EdgeInsets.only(right: 4.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(4.r)), color: ColorStyle.cFF650F),
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
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
                            item.createdAt != null ? DateFormat('yyyy.MM.dd').format(item.createdAt!) : '',
                            style: TextStyle(
                              color: '#999999'.hexColor,
                              fontSize: 10.sp,
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
