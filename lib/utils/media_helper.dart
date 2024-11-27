import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class MediaHelper {
  ///图片点击效果 预览图集合
  void imagePerView(
      BuildContext context, List<String> imageUrlList, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
          body: GestureDetector(
              onTap: () {
                Navigator.pop(context); // 关闭当前路由，返回原页面
              },
              child: PhotoViewGallery(
                pageOptions: imageUrlList
                    .map((url) => PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(url)))
                    .toList(),
              )));
    }));
  }

  ///视频展示 播放
  Widget videoFilePlay(String videoUrl) {
    late VideoPlayerController _controller;
    late Future<void> _initializeVideoPlayerFuture;
    _controller = VideoPlayerController.file(
      File(videoUrl), // 替换为您的视频 URL
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget cacheLoadNetworkImage(
      String imgUrl, double imgWidth, double imgHeight) {
    return RepaintBoundary(child: CachedNetworkImage(
      width: imgWidth,
      height: imgHeight,
      fit: BoxFit.cover,
      imageUrl: imgUrl.isNotEmpty ? imgUrl : '',
      placeholder: (context, url) =>
          Image.asset('assets/images/image_loading_def.png'),
      errorWidget: (context, url, error) =>
          Image.asset('assets/images/image_loading_def.png'),
    ));
  }
}
