import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../../model/search_top.dart';
import '../../../../widget/common_image.dart';

class CourseAllItem extends StatelessWidget {
  final BoxDecoration? boxDecoration;

  const CourseAllItem({
    super.key,
    this.boxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration ??
          BoxDecoration(
            color: '#F9FCFF'.hexColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommonImage.net(
                imageUrl: '',
                radius: 4.r,
                width: 88.w,
                height: 88.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '课程标题文字最多十字',
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.w),
                    Text(
                      '知识点最多也是十个字',
                      style: TextStyle(
                        color: '#666666'.hexColor,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          Row(
            children: [
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconKnowledge,
                  count: 88,
                  total: 88,
                ),
              ),
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconChallenge,
                  count: 88,
                  total: 88,
                ),
              ),
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconPractice,
                  count: 88,
                  total: 88,
                ),
              ),
              CourseStatusBtn(
                status: Random().nextInt(3),
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CourseTypeItem extends StatelessWidget {
  const CourseTypeItem({
    super.key,
    required this.assetName,
    required this.count,
    required this.total,
  });

  final String assetName;
  final num count;
  final num total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          SvgPicture.asset(
            assetName,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 4.w),
          Text.rich(
            TextSpan(
              text: '$count',
              children: [
                TextSpan(
                  text: '/$total',
                  style: TextStyle(
                    color: '#666666'.hexColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              color: '#333333'.hexColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseStatusBtn extends StatelessWidget {
  final int status;
  final VoidCallback? onTap;

  const CourseStatusBtn({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    Color bgColor = Colors.transparent;
    Color textColor = Colors.transparent;
    if (status == 0) {
      title = '未开始';
      bgColor = '#333333'.hexColor.withOpacity(0.1);
      textColor = '#333333'.hexColor;
    } else if (status == 1) {
      title = '进行中';
      bgColor = '#557BF6'.hexColor.withOpacity(0.1);
      textColor = '#557BF6'.hexColor;
    } else if (status == 2) {
      title = '已完成';
      bgColor = '#557BF6'.hexColor;
      textColor = Colors.white;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // 设置内边距
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
