import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/widget/common_image.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';
import '../../../routes/app_routes_utils.dart';
import '../../../utils/env.dart';
import '../../../utils/net_request.dart';
import '../../../utils/toast_utils.dart';
import '../../../utils/track_utils.dart';
import '../../../widget/like_button/like_button.dart';
import '../../home/home_screen.dart';
import '../video_detail_screen.dart';

class RecommendedVideosWidget extends StatefulWidget {
  final ArticleDetailBean? detailBean;
  final List<RecommendVideoModel> videos;
  final Function(RecommendVideoModel recommendVideo)? onVideoTap;

  const RecommendedVideosWidget({
    super.key,
    required this.videos,
    this.onVideoTap,
    this.detailBean,
  });

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

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    final success = await _likeToggle.call();
    return success ? !isLiked : isLiked;
  }

  Future<bool> _likeToggle() async {
    if (widget.detailBean == null) {
      return false;
    }
    final data = await NetRequest().newContentLike({
      'relType': NetRequest.COMMENT_TYPE_CONTENT,
      'relId': widget.detailBean!.id,
      'state': widget.detailBean!.liked ?? false ? false : true,
    });
    if (data is int) {
      if (widget.detailBean!.liked != true) {
        ToastUtils.showToast('点赞成功');
        TrackUtils.trackEvent(userLogType: '103003', params: widget.detailBean!.id);
      } else {
        ToastUtils.showToast('取消点赞成功');
      }
      if (widget.detailBean!.liked == true) {
        widget.detailBean!.liked = false;
        widget.detailBean!.likeCount = (widget.detailBean!.likeCount ?? 0) - 1;
      } else {
        widget.detailBean!.liked = true;
        widget.detailBean!.likeCount = (widget.detailBean!.likeCount ?? 0) + 1;
      }
      setState(() {});
      return true;
    }
    return false;
  }

  void _favoriteToggle() {
    if (widget.detailBean == null) {
      return;
    }
    if (!AppRoutesUtils.haveLogin(title: '请登录后收藏', content: '您当前的身份为访客\n登录后即可收藏精彩内容')) {
      return;
    }
    NetRequest().favoriteToggle(
      NetRequest.COMMENT_TYPE_CONTENT,
      widget.detailBean!.id,
      !(widget.detailBean!.favorited ?? false),
      (data) {
        if (widget.detailBean!.favorited != true) {
          ToastUtils.showToast('收藏成功');
        } else {
          ToastUtils.showToast('取消收藏成功');
        }
        if (widget.detailBean!.favorited == true) {
          widget.detailBean!.favorited = false;
          widget.detailBean!.favoriteCount = (widget.detailBean!.favoriteCount ?? 0) - 1;
        } else {
          widget.detailBean!.favorited = true;
          widget.detailBean!.favoriteCount = (widget.detailBean!.favoriteCount ?? 0) + 1;
        }
        setState(() {});
      },
      (msg) {
        AppRoutesUtils.haveCollect();
      },
    );
  }

  void _toShare() {
    NetRequest().upCount(widget.detailBean!.id, (data) async {
      await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${VideoDetailController.of.shareLink}'));
      ToastUtils.showToast('分享成功，链接已复制');
      TrackUtils.trackEvent(userLogType: '103005', params: widget.detailBean!.id);
      widget.detailBean!.shareCount = (widget.detailBean!.shareCount ?? 0) + 1;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                        isLiked: widget.detailBean?.liked == true,
                        size: 24.w,
                        padding: EdgeInsets.zero,
                        onTap: onLikeButtonTapped,
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
                    onTap: _favoriteToggle,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          widget.detailBean?.favorited == true
                              ? Assets.svg.iconBottomFavorited
                              : Assets.svg.iconBottomFavorite,
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
                    onTap: _toShare,
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
          ),
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
              widget.videos.length > 3 ? 3 : widget.videos.length,
              (index) {
                final video = widget.videos[index];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onVideoTap?.call(video),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
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
                      ),
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
