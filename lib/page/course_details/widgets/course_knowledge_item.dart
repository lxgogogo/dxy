import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../../model/course_model.dart';
import '../../../../widget/common_image.dart';

class CourseDetailKnowledgeItem extends StatelessWidget {
  final CourseModel item;
  final VoidCallback? onTap;

  const CourseDetailKnowledgeItem({
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
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.iconKnowledge,
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '知识',
                style: TextStyle(
                  color: '#000000'.hexColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.w),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.infoTitle ?? '',
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 28.w,
                  padding: EdgeInsets.all(1.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(28.r)),
                    gradient: LinearGradient(
                      colors: [
                        '#557BF6'.hexColor.withOpacity(0.4),
                        '#557BF6'.hexColor.withOpacity(0),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(28.r)),
                      color: Colors.white,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(28.r)),
                        gradient: LinearGradient(
                          colors: [
                            '#557BF6'.hexColor.withOpacity(0.2),
                            '#557BF6'.hexColor.withOpacity(0),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            Assets.svg.iconToKnomledge,
                            width: 16.w,
                            height: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '观看${item.contentType.sourceTypeDesc}',
                            style: TextStyle(
                              color: '#557BF6'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '进度：',
                        children: [
                          TextSpan(
                            text: '${item.completed ?? 0}',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '/${item.total ?? 0}',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: '#666666'.hexColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.svg.iconCourseIntegral,
                          width: 16.w,
                          height: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${item.integral ?? 0}',
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: double.infinity,
                    height: 4.w,
                    margin: EdgeInsets.symmetric(vertical: 8.w),
                    decoration: BoxDecoration(
                      color: '#333333'.hexColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: item.progress * constraints.maxWidth,
                            color: '#557BF6'.hexColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Wrap(
                    spacing: 5.w,
                    children: List.generate(
                      item.total ?? 0,
                      (index) {
                        final isCompleted = index < (item.completed ?? 0);
                        return Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isCompleted ? '#557BF6'.hexColor.withOpacity(0.1) : '#333333'.hexColor.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isCompleted ? '#557BF6'.hexColor : '#333333'.hexColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
