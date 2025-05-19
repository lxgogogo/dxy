import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/size_fit.dart';

import '../utils/app_theme.dart';

class FollowBtn extends StatelessWidget {
  final bool isFollowed;
  final bool isFans;
  final Function onTap;

  const FollowBtn({super.key, required this.isFollowed, required this.isFans, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String title = '关注';
    if (isFans && isFollowed) {
      title = '互相关注';
    } else if (!isFans && isFollowed) {
      title = '已关注';
    } else if (isFans && !isFollowed) {
      title = '回关';
    }
    SizeFit.initialize(context);
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 72.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFollowed
              ? isFans
                  ? '#557BF6'.hexColor.withOpacity(0.1)
                  : '#333333'.hexColor.withOpacity(0.1)
              : '#557BF6'.hexColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // 设置内边距
        child: Text(
          title,
          style: TextStyle(
            color: isFollowed
                ? isFans
                    ? '#557BF6'.hexColor
                    : '#333333'.hexColor
                : Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
