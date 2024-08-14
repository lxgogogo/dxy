import 'package:flutter/material.dart';
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
          color: isFollowed ? AppTheme.color_0D000000 : AppTheme.color_008EFF,
          borderRadius: BorderRadius.circular(12.px),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
        child: Text(isFollowed ? '已关注' : '关注',
            style: isFollowed
                ? TextStyle(color: const Color(0xff95A3C4), fontSize: 10.px)
                : TextStyle(color: const Color(0xffffffff), fontSize: 10.px)),
      ),
    );
  }
}
