import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_model.dart';

import '../../../../widget/common_image.dart';

class CourseDetailAllItem extends StatelessWidget {
  final CourseModel item;
  final VoidCallback? onTap;

  const CourseDetailAllItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: '#58A5FF'.hexColor.withOpacity(0.1),
            blurRadius: 8.63.r,
            offset: Offset(0, 4.32.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.title ?? '',
            style: TextStyle(
              color: '#333333'.hexColor,
              fontSize: 14.sp,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.w),
          Row(
            children: [
              CommonImage.net(
                imageUrl: item.icon ?? '',
                width: 20.w,
                height: 20.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconKnowledge,
                  count: item.knowledgeCompleted ?? 0,
                  total: item.knowledgeTotal ?? 0,
                  status: item.state,
                ),
              ),
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconChallenge,
                  count: item.challengeCompleted ?? 0,
                  total: item.challengeTotal ?? 0,
                  status: item.state,
                ),
              ),
              Expanded(
                child: CourseTypeItem(
                  assetName: Assets.svg.iconPractice,
                  count: item.practiseCompleted ?? 0,
                  total: item.practiseTotal ?? 0,
                  status: item.state,
                ),
              ),
              CourseStatusBtn(
                status: item.state,
                onTap: onTap,
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
    required this.status,
  });

  final String assetName;
  final num count;
  final num total;

  //0 未开始   1进行中  2已完成
  final int? status;

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
              text: status == 0 ? '' : '$count/',
              children: [
                TextSpan(
                  text: '$total',
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
  //0 未开始   1进行中  2已完成
  final int? status;
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
      title = '点击开始';
      bgColor = '#557BF6'.hexColor;
      textColor = Colors.white;
    } else if (status == 1) {
      title = '进行中';
      bgColor = '#557BF6'.hexColor.withOpacity(0.1);
      textColor = '#557BF6'.hexColor;
    } else if (status == 2) {
      title = '已完成';
      bgColor = '#333333'.hexColor.withOpacity(0.1);
      textColor = '#333333'.hexColor;
    }
    return GestureDetector(
      onTap: () {
        if (status == 0) {
          onTap?.call();
        }
      },
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
