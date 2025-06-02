import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../../widget/common_image.dart';

class CourseChallengeItem extends StatelessWidget {
  final BoxDecoration? boxDecoration;

  const CourseChallengeItem({
    super.key,
    this.boxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w).copyWith(right: 0),
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
                width: 24.w,
                height: 24.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '课程标题文字最多十字',
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
                            Assets.svg.iconToChallenge,
                            width: 16.w,
                            height: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '去挑战',
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '进度：',
                        children: [
                          TextSpan(
                            text: '88',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '/88',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: '#666666'.hexColor,
                        fontSize: 12.sp,
                      ),
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
                            width: 0.8 * constraints.maxWidth,
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
                    3,
                    (index) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            index.isEven ? Assets.svg.iconChecked : Assets.svg.iconUncheck,
                            width: 16.w,
                            height: 16.w,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w, right: 24.w),
                              child: Text(
                                '挑战名称最多可以十五个中文字数',
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
                                '8888888',
                                style: TextStyle(
                                  color: '#333333'.hexColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
