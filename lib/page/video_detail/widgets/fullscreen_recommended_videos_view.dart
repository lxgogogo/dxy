import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/recommend_video_model.dart';
import '../../../widget/like_button/like_button.dart';
import 'item_recommended_video.dart';

class FullscreenRecommendedVideosView extends StatefulWidget {
  final bool liked;
  final LikeButtonTapCallback? likeToggle;
  final bool favorited;
  final Function? favoriteToggle;
  final Function? toShare;
  final List<RecommendVideoModel> videos;
  final Function(RecommendVideoModel recommendVideo)? onVideoTap;
  final VoidCallback? onReplay;
  final Function(RecommendVideoModel model)? onPlayNewVideo;
  final Timer? recommendTimer;
  final VoidCallback? onCancelTimer; // 添加取消timer的回调

  const FullscreenRecommendedVideosView({
    super.key,
    required this.liked,
    required this.favorited,
    required this.videos,
    this.onVideoTap,
    this.likeToggle,
    this.favoriteToggle,
    this.toShare,
    this.onReplay,
    this.onPlayNewVideo,
    this.recommendTimer,
    this.onCancelTimer,
  });

  @override
  State<FullscreenRecommendedVideosView> createState() => _FullscreenRecommendedVideosViewState();
}

class _FullscreenRecommendedVideosViewState extends State<FullscreenRecommendedVideosView>
    with SingleTickerProviderStateMixin {
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Opacity(
                      opacity: widget.recommendTimer?.isActive == true ? 1 : 0,
                      child: GestureDetector(
                        onTap: _cancelAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(49),
                          ),
                          child: const Text(
                            '取消连播',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 12,
                        children: List.generate(
                          widget.videos.length,
                          (index) {
                            final video = widget.videos[index];
                            return GestureDetector(
                              onTap: () => widget.onVideoTap?.call(video),
                              child: SizedBox(
                                width: 180,
                                child: Column(
                                  spacing: 8,
                                  children: [
                                    RecommendVideoItem(
                                      onTap: () => widget.onPlayNewVideo?.call(video),
                                      recommendVideo: video,
                                      animationController: _animationController,
                                      showAnimate: index == 0 && widget.recommendTimer?.isActive == true,
                                      isFullScreen: true,
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
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
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
                      color: isLiked ? null : Colors.white,
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
                    color: widget.favorited == true ? null : Colors.white,
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
                    color: Colors.white,
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
