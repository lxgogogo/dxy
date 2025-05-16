import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

class HomeMenuItem extends StatelessWidget {
  const HomeMenuItem({
    super.key,
    required this.itemWidth,
    required this.name,
    required this.nameEn,
    required this.imagePath,
    this.onTap,
  });

  final double itemWidth;
  final String name;
  final String nameEn;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: itemWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: '#0050FF'.hexColor.withOpacity(0.1),
                  offset: Offset(0, 5.w),
                  blurRadius: 10.r,
                ),
              ],
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: AspectRatio(
              aspectRatio: 164 / 63,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.w, right: 14.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 16.sp,
                            ),
                          ),
                          Container(
                            color: '#333333'.hexColor.withOpacity(0.05),
                            margin: EdgeInsets.symmetric(vertical: 2.w),
                            height: 1.w,
                          ),
                          Text(
                            nameEn,
                            style: TextStyle(
                              color: '#999999'.hexColor,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    imagePath,
                    width: 60.w,
                    height: 60.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
