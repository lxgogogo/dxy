import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_model.dart';

import '../../../../widget/common_image.dart';

class CourseDetailChallengeItem extends StatelessWidget {
  final CourseModel item;
  final VoidCallback? onTap;
  final Function? itemOnTap;

  const CourseDetailChallengeItem({
    super.key,
    required this.item,
    this.onTap,
    this.itemOnTap
  });

  @override
  Widget build(BuildContext context) {
    int integral = 0;
    for (ChallengeIndexDtoList m in item.challengeIndexDtoList ?? []) {
      integral += (m.integral ?? 0);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w).copyWith(right: 0),
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
                  Assets.svg.iconChallenge,
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  '挑战',
                  style: TextStyle(
                    color: '#000000'.hexColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
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
                            '$integral',
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
                  Wrap(
                    runSpacing: 12.w,
                    children: List.generate(
                      item.challengeIndexDtoList?.length ?? 0,
                      (index) {
                        final childItem = item.challengeIndexDtoList![index];
                        return GestureDetector(
                          onTap: () {
                            if (itemOnTap != null) {
                              itemOnTap!(item, childItem);
                            }
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                childItem.status == 1 ? Assets.svg.iconChecked : Assets.svg.iconUncheck,
                                width: 16.w,
                                height: 16.w,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.w, right: 24.w),
                                  child: Text(
                                    childItem.content ?? '',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                    ),
                                  ),
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
                                    '${childItem.integral ?? 0}',
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
