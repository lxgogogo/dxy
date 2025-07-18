import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/common_image.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';
import '../../../widget/like_button/like_button.dart';

class RecommendedVideosWidget extends StatefulWidget {
  final bool liked;
  final LikeButtonTapCallback? likeToggle;
  final bool favorited;
  final Function? favoriteToggle;
  final Function? toShare;
  final List<RecommendVideoModel> videos;
  final Function(RecommendVideoModel recommendVideo)? onVideoTap;
  final bool isFullScreen;
  final VoidCallback? onReplay;

  const RecommendedVideosWidget(
      {super.key,
      required this.liked,
      required this.favorited,
      required this.videos,
      this.onVideoTap,
      this.likeToggle,
      this.favoriteToggle,
      this.toShare,
      this.isFullScreen = false,
      this.onReplay});

  @override
  State<RecommendedVideosWidget> createState() => _RecommendedVideosWidgetState();
}

class _RecommendedVideosWidgetState extends State<RecommendedVideosWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videos.isNotEmpty) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      )..forward();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onVideoTap?.call(widget.videos.first);
        }
      });
    }
  }

  void _cancelAnimation() {
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: SvgPicture.asset(
                        Assets.svg.iconBack,
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionsRow(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '推荐视频',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (_controller.isAnimating)
                        GestureDetector(
                          onTap: () {
                            _cancelAnimation();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(49),
                            ),
                            child: const Text(
                              '取消联播',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12,
                      children: List.generate(
                        widget.videos.length,
                        (index) {
                          final video = widget.videos[index];
                          return GestureDetector(
                            onTap: () => widget.onVideoTap?.call(video),
                            child: _buildVideoItem(video, index),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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
                    Container(
                      width: 126.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CommonImage.net(
                            imageUrl: widget.videos.first.cover ?? '',
                          ),
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    Assets.svg.iconPlayProgress,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: Size(24.w, 24.w),
                                        painter: _CircleCountdownPainter(_controller.value),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                              if (_controller.isAnimating)
                                GestureDetector(
                                  onTap: () {
                                    _cancelAnimation();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(49.r),
                                    ),
                                    child: Text(
                                      '取消联播',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
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

  Widget _buildVideoItem(RecommendVideoModel video, int index) {
    return SizedBox(
      width: 180,
      child: Column(
        spacing: 8,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CommonImage.net(
                  imageUrl: video.cover ?? '',
                ),
                if (index == 0 && _controller.isAnimating) ...[
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.svg.iconPlayProgress,
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(24.w, 24.w),
                                painter: _CircleCountdownPainter(_controller.value),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            video.title ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: widget.onReplay,
          child: Column(
            spacing: 8,
            children: [
              SvgPicture.asset(
                Assets.svg.iconReplay,
                width: 20,
                height: 20,
              ),
              const Text(
                '重播',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Row(
          spacing: 24,
          children: [
            Column(
              spacing: 8,
              children: [
                LikeButton(
                  isLiked: widget.liked == true,
                  size: 24,
                  padding: EdgeInsets.zero,
                  onTap: widget.likeToggle,
                  likeBuilder: (bool isLiked) {
                    return SvgPicture.asset(
                      isLiked ? Assets.svg.iconBottomLiked : Assets.svg.iconBottomLike,
                    );
                  },
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Color(0xFF557BF6),
                    dotSecondaryColor: Color(0xFF557BF6),
                    dotThirdColor: Color(0xFF557BF6),
                    dotLastColor: Color(0xFF557BF6),
                  ),
                  circleColor: const CircleColor(
                    start: Color(0xFF557BF6),
                    end: Color(0xFF557BF6),
                  ),
                  likeCountPadding: EdgeInsets.zero,
                  countBuilder: (_, __, ___) => const SizedBox(),
                ),
                const Text(
                  '点赞',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => widget.favoriteToggle?.call(),
              child: Column(
                spacing: 8,
                children: [
                  SvgPicture.asset(
                    widget.favorited == true ? Assets.svg.iconBottomFavorited : Assets.svg.iconBottomFavorite,
                    width: 24,
                    height: 24,
                  ),
                  const Text(
                    '收藏',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.toShare?.call(),
              child: Column(
                spacing: 8,
                children: [
                  SvgPicture.asset(
                    Assets.svg.iconBottomShare,
                    width: 24,
                    height: 24,
                  ),
                  const Text(
                    '转发',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleCountdownPainter extends CustomPainter {
  final double progress;

  _CircleCountdownPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final double radius = size.width / 2 - 1.5.w;
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
