import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../model/course_model.dart';

class KnowledgeVideoView extends StatefulWidget {
  final ContentVideo? contentVideo;
  final VoidCallback? onTapDetail;

  const KnowledgeVideoView({super.key, required this.contentVideo, this.onTapDetail});

  @override
  State<KnowledgeVideoView> createState() => _KnowledgeVideoViewState();
}

class _KnowledgeVideoViewState extends State<KnowledgeVideoView> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    _startVideoPlayer(widget.contentVideo?.sourceUrl ?? '');
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
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
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          showOptions: false,
          showControlsOnInitialize: false,
        );
        if (mounted) {
          setState(() {});
        }
      });
  }

  Future<void> _startVideoPlayer(String link) async {
    if (videoPlayerController == null) {
      _initController(link);
    } else {
      final oldController = videoPlayerController;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController?.dispose();
        _initController(link);
      });
      videoPlayerController = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
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
            chewieController != null
                ? Chewie(
                    controller: chewieController!,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            Positioned(
              top: 12.w,
              right: 12.w,
              child: GestureDetector(
                onTap: widget.onTapDetail,
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
    );
  }
}
