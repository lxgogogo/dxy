import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:video_player/video_player.dart';

class HtmlFactoryBuilder extends WidgetFactory {
  final BuildContext context;
  final String content;

  HtmlFactoryBuilder(this.context, {required this.content});

  @override
  void parse(BuildTree meta) {
    if (meta.element.localName == 'td' || meta.element.localName == 'th') {
      meta.register(
        BuildOp(onRenderedBlock: (BuildTree tree, Widget block) {}),
      );
    }
    super.parse(meta);
  }

  /// Builds [Image].
  @override
  Widget? buildImageWidget(BuildTree tree, ImageSource src) {

    final url = src.url;

    ImageProvider? provider;
    if (url.startsWith('asset:')) {
      provider = imageProviderFromAsset(url);
    } else if (url.startsWith('data:image/')) {
      provider = imageProviderFromDataUri(url);
    } else if (url.startsWith('file:')) {
      provider = imageProviderFromFileUri(url);
    } else {
      // provider = imageProviderFromNetwork(url);
      final image = src.image;
      final semanticLabel = image?.alt ?? image?.title;
      return LayoutBuilder(builder: (context, constraints) {

        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.fill,
          placeholder: (context, url) => Image.asset(
            'assets/images/image_loading_def.png',
            width: constraints.maxWidth / 1.5,
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/image_loading_def.png',
            width: constraints.maxWidth / 1.5,
          ),
        );
      });
    }
    if (provider == null) {
      return null;
    }
    return super.buildImageWidget(tree, src);
  }

  @override
  Widget? buildVideoPlayer(
    BuildTree tree,
    String url, {
    required bool autoplay,
    required bool controls,
    double? height,
    required bool loop,
    String? posterUrl,
    double? width,
  }) {
    return VideoPlayer(
      url,
      aspectRatio: 16 / 9,
      autoResize: true,
      autoplay: autoplay,
      controls: controls,
      errorBuilder: (context, _, error) => onErrorBuilder(context, tree, error, url) ?? widget0,
      loadingBuilder: (context, _, child) => onLoadingBuilder(context, tree, null, url) ?? widget0,
      loop: loop,
      poster: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: posterUrl ?? '',
        placeholder: (context, url) => const SizedBox(),
        errorWidget: (context, url, error) => const SizedBox(),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String url;

  final double aspectRatio;

  final bool autoResize;

  final bool autoplay;

  final bool controls;

  final Widget Function(BuildContext context, String url, dynamic error)? errorBuilder;

  final Widget Function(BuildContext context, String url, Widget child)? loadingBuilder;

  final bool loop;

  final Widget? poster;

  const VideoPlayer(
    this.url, {
    required this.aspectRatio,
    this.autoResize = true,
    this.autoplay = false,
    this.controls = false,
    this.errorBuilder,
    super.key,
    this.loadingBuilder,
    this.loop = false,
    this.poster,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  void _initController(String link) {
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: false,
          showOptions: false,
          showControlsOnInitialize: false,
          // deviceOrientationsOnEnterFullScreen: DeviceOrientation.values,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        );
        setState(() {});
      });
  }

  Future<void> _startVideoPlayer(String link) async {
    if (videoController == null) {
      _initController(link);
    } else {
      final oldController = videoController;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController?.dispose();
        _initController(link);
      });
      videoController = null;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVideoPlayer(widget.url);
    });
  }

  @override
  void dispose() {
    videoController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (videoController?.value.isPlaying == true) {
          videoController?.pause();
        } else {
          videoController?.play();
        }
      },
      child: Container(
        height: 180.w,
        margin: EdgeInsets.symmetric(vertical: 16.w),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffa2b9d0).withOpacity(0.64),
              offset: Offset(0, 1.w),
              blurRadius: 2.r,
              spreadRadius: -1.w,
            ),
            BoxShadow(
              color: const Color(0xffffffff),
              offset: Offset(0, -1.w),
              blurRadius: 2.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: chewieController != null
            ? Chewie(
                controller: chewieController!,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.poster != null) widget.poster!,
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
      ),
    );
  }
}
