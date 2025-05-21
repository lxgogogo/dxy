import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

typedef LoginSuccess = void Function(dynamic data);
typedef GetUserInfoSuccess = void Function(dynamic data);

class LoginHelper {

  //获取图像
  Widget getUserAvatar(String avatarUrl, double width, double height) {
    return RepaintBoundary(child: CachedNetworkImage(
      width: width,
      height: height,
      fit: BoxFit.cover,
      imageUrl: avatarUrl.isNotEmpty ? avatarUrl : '',
      placeholder: (context, url) =>
          Image.asset('assets/images/default_avatar.png'),
      errorWidget: (context, url, error) =>
          Image.asset('assets/images/default_avatar.png'),
    ),);
  }
}
