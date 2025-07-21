import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/widget/common_image.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';

class RecommendVideoItem extends StatelessWidget {
  const RecommendVideoItem({
    super.key,
    required this.recommendVideo,
    required this.animationController,
    this.isFullScreen = false,
    this.showAnimate = true,
    this.onTap,
  });

  final RecommendVideoModel recommendVideo;
  final AnimationController animationController;
  final bool isFullScreen;
  final bool showAnimate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullScreen ? 180 : 126.w,
        height: isFullScreen ? 100 : 70.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CommonImage.net(
              imageUrl: recommendVideo.cover ?? '',
            ),
            if (showAnimate) ...[
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
              Center(
                child: SizedBox(
                  width: isFullScreen ? 36 : 24,
                  height: isFullScreen ? 36 : 24,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.svg.iconPlayProgress,
                      ),
                      AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(
                              isFullScreen ? 36 : 24,
                              isFullScreen ? 36 : 24,
                            ),
                            painter: _CircleCountdownPainter(animationController.value),
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
