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
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: '#1E1E1E'.hexColor,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(width: 6.w),
              // SvgPicture.asset(
              //   Assets.svg.homeTag,
              //   width: 34.w,
              // ),
            ],
          ),
        ),
        subtitle ??
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    '更多',
                    style: TextStyle(
                      color: '#1E1E1E'.hexColor.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
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
