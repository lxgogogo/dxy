import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';
import '../../../widget/like_button/like_button.dart';
import 'item_recommended_video.dart';

class NormalRecommendedVideosView extends StatefulWidget {
  final List<RecommendVideoModel> videos;
  final Function(RecommendVideoModel recommendVideo)? onVideoTap;
  final VoidCallback? onReplay;
  final Function(RecommendVideoModel model)? onPlayNewVideo;

  const NormalRecommendedVideosView({
    super.key,
    required this.videos,
    this.onVideoTap,
    this.onReplay,
    this.onPlayNewVideo,
  });

  @override
  State<NormalRecommendedVideosView> createState() => _NormalRecommendedVideosViewState();
}

class _NormalRecommendedVideosViewState extends State<NormalRecommendedVideosView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (widget.videos.isNotEmpty) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed && _isAnimating) {
          widget.onPlayNewVideo?.call(widget.videos.first);
        }
      });
      _animationController.forward();
      _isAnimating = true;
      setState(() {});
    }
  }

  void _cancelAnimation() {
    if (!_isAnimating) return;
    _animationController.stop();
    _animationController.reset();
    _isAnimating = false;
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
                    RecommendVideoItem(
                      onTap: () => widget.onPlayNewVideo?.call(widget.videos.first),
                      recommendVideo: widget.videos.first,
                      animationController: _animationController,
                      showAnimate: _isAnimating,
                      isFullScreen: false,
                    ),
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
                                onTap: widget.onReplay,
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
                              if (_isAnimating)
                                GestureDetector(
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
                                ),
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
