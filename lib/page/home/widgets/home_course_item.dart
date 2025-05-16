import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/track_utils.dart';

class HomeCourseItem extends StatelessWidget {
  const HomeCourseItem({
    super.key,
    required this.itemWidth,
    required this.imagePath,
    required this.title,
    required this.subtitles,
  });

  final double itemWidth;
  final String imagePath;
  final String title;
  final List<String> subtitles;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: TrackUtils.trackedTap(
        onTap: () => Get.toNamed(Routes.course, arguments: {'title': title}),
        userLogType: '101010',
      ),
      child: Container(
        width: itemWidth,
        height: itemWidth / (166 / 204),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.courseCardBg.provider(),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              imagePath,
              width: 44.w,
              height: 44.w,
            ),
            SizedBox(height: 12.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 6.w),
            ...subtitles.map(
              (e) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(top: 6.w),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.4, sigmaY: 4.4),
                    child: Container(
                      width: double.infinity,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.w),
          ],
        ),
      ),
    );
  }
}
