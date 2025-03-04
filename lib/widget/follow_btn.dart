import 'package:flutter/material.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/size_fit.dart';

import '../utils/app_theme.dart';

class FollowBtn extends StatelessWidget {
  bool isFollowed;
  var onTap;
  FollowBtn({super.key, required this.isFollowed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.px,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFollowed ?'#333333'.hexColor.withOpacity(0.1) : '#557BF6'.hexColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.px),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), // 设置内边距
        child: Text(isFollowed ? '已关注' : '关注',
            style: isFollowed
                ? TextStyle(color:'#333333'.hexColor, fontSize: 10.px)
                : TextStyle(color: '#557BF6'.hexColor, fontSize: 10.px)),
      ),
    );
  }
}
