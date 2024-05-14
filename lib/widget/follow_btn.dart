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
        child: Container(
          decoration: BoxDecoration(
            color: isFollowed ? AppTheme.color_0D000000 : AppTheme.color_008EFF,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
          child: Text(isFollowed ? '已关注' : '关注',
              style: isFollowed
                  ? AppTheme.text999999Size14
                  : AppTheme.textFFFFFFSize14),
        ),
        onTap: onTap);
  }
}
