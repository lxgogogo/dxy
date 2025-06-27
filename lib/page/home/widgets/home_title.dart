import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

class HomeTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? subtitle;

  const HomeTitle({
    super.key,
    required this.title,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: '#333333'.hexColor,
              fontSize: 18.sp,
            ),
          ),
        ),
        if (subtitle != null)
          subtitle!
        else if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  '更多',
                  style: TextStyle(
                    color: '#999999'.hexColor,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                SvgPicture.asset(
                  Assets.svg.iconMore,
                  width: 12.w,
                  height: 12.w,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
