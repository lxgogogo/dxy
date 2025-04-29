import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';

import '../../model/user.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import '../../utils/storage.dart';
import '../../utils/toast_utils.dart';
import '../main/main_screen.dart';

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
