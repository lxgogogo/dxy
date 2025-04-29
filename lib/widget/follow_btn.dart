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
        width: 70.w,
        height: 28.w,
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: isFollowed ? '#EBEBEB'.hexColor : '#557BF6'.hexColor,
          borderRadius: BorderRadius.circular(4.w),
        ),// 设置内边距
        child: Text(title,
            style: isFollowed
                ? TextStyle(color:'#333333'.hexColor, fontSize: 12.sp)
                : TextStyle(color: Colors.white, fontSize: 12.sp)),
      ),
    );
  }
}
