import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/common_image.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../gen/assets.gen.dart';
import '../model/article.dart';
import '../routes/app_pages.dart';
import '../utils/color_style_util.dart';
import 'count_widget.dart';
import 'duration_text.dart';

class ItemVideoPreview extends StatefulWidget {
  final ArticleBean item;
  final VoidCallback? onTap;

  const ItemVideoPreview({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<ItemVideoPreview> createState() => _ItemVideoPreviewState();
}

class _ItemVideoPreviewState extends State<ItemVideoPreview> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    _startVideoPlayer(widget.item.previewUrl ?? '');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ItemVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.previewUrl != widget.item.previewUrl) {
      _startVideoPlayer(widget.item.previewUrl ?? '');
    }
  }

  void _initController(String link) {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(link),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoInitialize: true,
          autoPlay: true,
          looping: true,
          showControlsOnInitialize: false,
          showOptions: false,
          overlay: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoController!,
              builder: (_, videoPlayerValue, __) {
                if (videoPlayerValue.position > Duration.zero) {
                  return const SizedBox();
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CommonImage.net(
                      imageUrl: widget.item.cover ?? '',
                    ),
                  ],
                );
              }),
        );
        _chewieController!.setVolume(0);
        if (mounted) {
          setState(() {});
        }
      });
  }

  Future<void> _startVideoPlayer(String link) async {
    isVideoCompleted = false;
    if (_videoController == null) {
      _initController(link);
    } else {
      final oldController = _videoController;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController?.dispose();
        _initController(link);
      });
      _videoController = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.videoDetail,
          arguments: {'id': widget.item.id},
        );
        widget.onTap?.call();
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 166 / 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _chewieController != null
                            ? IgnorePointer(
                                child: Chewie(
                                  controller: _chewieController!,
                                ),
                              )
                            : CommonImage.net(
                                imageUrl: widget.item.cover ?? '',
                              ),
                      ],
                    ),
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
                              '${widget.item.viewCount?.abbreviateNumber ?? '0'}次播放',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                          DurationText(
                            durationInSeconds: widget.item.duration ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.item.type == 'videoList')
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
                  if (widget.item.featured == 1)
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
                    widget.item.title ?? '',
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
                widget.item.createdAt != null ? DateFormat('yyyy.MM.dd').format(widget.item.createdAt!) : '',
                style: TextStyle(
                  color: '#999999'.hexColor,
                  fontSize: 10.sp,
                ),
              ),
              const Spacer(),
              CountLike(
                count: widget.item.likeCount.abbreviateNumber,
                usePlaceHolder: false,
              ),
              CountComment(
                count: widget.item.commentCount.abbreviateNumber,
                usePlaceHolder: false,
              ),
            ],
          )
        ],
      ),
    );
  }
}
