import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  const RecommendedVideosWidget(
      {super.key,
      required this.liked,
      required this.favorited,
      required this.videos,
      this.onVideoTap,
      this.likeToggle,
      this.favoriteToggle,
      this.toShare,
      this.isFullScreen = false});

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      final videos = widget.videos.take(3).toList();
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionsRow(),
            Text(
              '推荐视频',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.w),
            Row(
              spacing: 16.w,
              children: List.generate(
                videos.length,
                (index) {
                  final video = videos[index];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onVideoTap?.call(video),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _buildVideoItem(video, index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    final videos = widget.videos.take(1).toList();
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionsRow(),
          Text(
            '推荐视频',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.w),
          Row(
            spacing: 16.w,
            children: List.generate(
              videos.length,
              (index) {
                final video = videos[index];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onVideoTap?.call(video),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _buildVideoItem(video, index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(RecommendVideoModel video, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          CommonImage.net(
            imageUrl: video.cover ?? '',
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Text(
              video.title ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (index == 0) ...[
            Center(
              child: SizedBox(
                width: 32.w,
                height: 32.w,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(32.w, 32.w),
                          painter: _CircleCountdownPainter(_controller.value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4.w,
              left: 4.w,
              child: GestureDetector(
                onTap: () {
                  _cancelAnimation();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '取消联播',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '重播',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        Row(
          children: [
            Column(
              children: [
                LikeButton(
                  isLiked: widget.liked == true,
                  size: 24.w,
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
                Text(
                  '点赞',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => widget.favoriteToggle?.call(),
              child: Column(
                children: [
                  SvgPicture.asset(
                    widget.favorited == true ? Assets.svg.iconBottomFavorited : Assets.svg.iconBottomFavorite,
                    width: 24.w,
                    height: 24.w,
                  ),
                  Text(
                    '收藏',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.toShare?.call(),
              child: Column(
                children: [
                  SvgPicture.asset(
                    Assets.svg.iconBottomShare,
                    width: 24.w,
                    height: 24.w,
                  ),
                  Text(
                    '转发',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
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
      ..color = Colors.redAccent
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final double radius = size.width / 2;
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
