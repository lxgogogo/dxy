import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:video_player/video_player.dart';

import '../../../../model/course_model.dart';

class KnowledgeVideoView extends StatefulWidget {
  final ContentVideo? contentVideo;
  final Function({Duration? duration}) onTapDetail;
  final VoidCallback? onVideoComplete;

  const KnowledgeVideoView({
    super.key,
    required this.contentVideo,
    required this.onTapDetail,
    this.onVideoComplete,
  });

  @override
  State<KnowledgeVideoView> createState() => _KnowledgeVideoViewState();
}

class _KnowledgeVideoViewState extends State<KnowledgeVideoView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    _startVideoPlayer(widget.contentVideo?.sourceUrl ?? '');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KnowledgeVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentVideo?.sourceUrl != widget.contentVideo?.sourceUrl) {
      _startVideoPlayer(widget.contentVideo?.sourceUrl ?? '');
    }
  }

  void _initController(String link) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..addListener(_videoListener)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          showOptions: false,
          showControlsOnInitialize: false,
          overlay: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoController!,
              builder: (_, videoPlayerValue, __) {
                if (videoPlayerValue.position > Duration.zero) {
                  return const SizedBox();
                }
                return SizedBox.expand(
                  child: CachedNetworkImage(
                    imageUrl: widget.contentVideo?.thumbnail ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                );
              }),
        );
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
        oldController?.removeListener(_videoListener);
        await oldController?.dispose();
        _initController(link);
      });
      _videoController?.removeListener(_videoListener);
      _videoController = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _videoListener() {
    if (_videoController == null) return;
    if (!isVideoCompleted) {
      final currentDuration = _videoController!.value.position.inSeconds;
      if (currentDuration > 0) {
        final totalDuration = _videoController!.value.duration.inSeconds;
        if ((currentDuration + 1) >= totalDuration) {
          isVideoCompleted = true;
          widget.onVideoComplete?.call();
          Future.delayed(const Duration(milliseconds: 150), () {
            if (_chewieController?.isFullScreen == true) {
              _chewieController?.exitFullScreen();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusLost: () {
        _videoController?.pause();
      },
      child: AspectRatio(
        aspectRatio: 311 / 166,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _chewieController != null
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
              Positioned(
                top: 12.w,
                right: 12.w,
                child: GestureDetector(
                  onTap: () async {
                    final duration = await _videoController?.position;
                    widget.onTapDetail.call(duration: duration);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 28.w,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '页面查看',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
