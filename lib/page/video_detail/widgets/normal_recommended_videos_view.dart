import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';
import '../video_detail_screen.dart';
import 'item_recommended_video.dart';

class NormalRecommendedVideosView extends StatefulWidget {
  final List<RecommendVideoModel> videos;
  final VoidCallback? onReplay;
  final Function(RecommendVideoModel model)? onPlayNewVideo;
  final VoidCallback? onCancelTimer; // 添加取消timer的回调

  const NormalRecommendedVideosView({
    super.key,
    required this.videos,
    this.onReplay,
    this.onPlayNewVideo,
    this.onCancelTimer,
  });

  @override
  State<NormalRecommendedVideosView> createState() => _NormalRecommendedVideosViewState();
}

class _NormalRecommendedVideosViewState extends State<NormalRecommendedVideosView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    if (widget.videos.isNotEmpty) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );
      _animationController.forward();
    }
  }

  void _cancelAnimation() {
    // 调用Controller的取消方法
    widget.onCancelTimer?.call();
    // 停止本地动画
    _animationController.stop();
    _animationController.reset();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.w,
            children: [
              GestureDetector(
                onTap: Get.back,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  height: kToolbarHeight,
                  child: SvgPicture.asset(
                    Assets.svg.iconBack,
                    width: 24.w,
                    height: 24.w,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '推荐视频',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: '#999999'.hexColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  spacing: 8.w,
                  children: [
                    Obx(() {
                      return RecommendVideoItem(
                        onTap: () {
                          _cancelAnimation();
                          widget.onPlayNewVideo?.call(widget.videos.first);
                        },
                        recommendVideo: widget.videos.first,
                        animationController: _animationController,
                        showAnimate: !VideoDetailController.of.recommendTimerCancelled.value,
                        isFullScreen: false,
                      );
                    }),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 6.w,
                        children: [
                          Text(
                            widget.videos.first.title ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            spacing: 40.w,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _cancelAnimation();
                                  widget.onReplay?.call();
                                },
                                child: Row(
                                  spacing: 4.w,
                                  children: [
                                    SvgPicture.asset(
                                      Assets.svg.iconReplay,
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                    Text(
                                      '重播',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                Obx(() {
                                  if (!VideoDetailController.of.recommendTimerCancelled.value) {
                                    return GestureDetector(
                                      onTap: _cancelAnimation,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(49.r),
                                        ),
                                        child: Text(
                                          '取消连播',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
