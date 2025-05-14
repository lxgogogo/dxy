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
      child: SizedBox(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: itemWidth,
              child: AspectRatio(
                aspectRatio: 164 / 63,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16.6, sigmaY: 16.6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: '#0050FF'.hexColor.withOpacity(0.1),
                            offset: Offset(0, 5.w),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 108.w,
                            margin: EdgeInsets.only(left: 10.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: '#1E1E1E'.hexColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Container(
                                  color: '#C9C9C9'.hexColor.withOpacity(0.5),
                                  margin: EdgeInsets.symmetric(vertical: 2.5.w),
                                  width: 83.33,
                                  height: 0.42.w,
                                ),
                                Text(
                                  nameEn,
                                  style: TextStyle(
                                    color: '#AAAAAA'.hexColor.withOpacity(0.7),
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -3.w,
              bottom: 0,
              child: Image.asset(
                imagePath,
                width: 60.w,
                height: 60.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
