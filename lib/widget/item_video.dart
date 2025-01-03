import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/media_helper.dart';
import 'package:holdem/utils/size_fit.dart';

import 'linear_card.dart';

class VideoItem extends StatefulWidget {
  final ArticleBean article;
  final bool isBanner;

  const VideoItem({super.key, required this.article, this.isBanner = false});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.videoDetail, arguments: widget.article.id ?? 0)?.whenComplete(() {
          widget.article.viewCount = (widget.article.viewCount ?? 0) + 1;
          setState(() {});
        });
      },
      child: LinearCard(
        padding: EdgeInsets.only(bottom: 2.w),
        margin: EdgeInsets.only(
          left: widget.isBanner ? 12.w : 0,
          right: widget.isBanner ? 12.w : 0,
          top: widget.isBanner ? 12.w : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: widget.isBanner ? 200.w : 120.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.article.cover ?? '',
                    placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                    errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        'assets/images/video.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                  Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: 4.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.article.viewCount?.abbreviateNumber ?? '0'}次播放',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                          Container(
                            height: 16.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 7.w),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.w),
                              ),
                            ),
                            child: Text(
                              formatDuration(Duration(seconds: widget.article.duration ?? 0)),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      )),
                  if (widget.article.type == 'videoList')
                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          '合集',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 12.w, right: 12.w, top: widget.isBanner ? 10.w : 7.w, bottom: widget.isBanner ? 10.w : 0),
              child: Text(
                widget.article.title ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: widget.isBanner ? 1 : 2,
                style: TextStyle(
                  color: const Color(0xff2c2c2c),
                  fontSize: widget.isBanner ? 14.w : 12.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
