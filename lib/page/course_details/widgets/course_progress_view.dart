import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../../../model/course_model.dart';

class CourseProgressView extends StatelessWidget {
  final Function(int index)? onSelectItem;

  const CourseProgressView({
    super.key,
    required this.item,
    this.onSelectItem,
  });

  final CourseModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      // fontWeight: FontWeight.w700,
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
            if (UserStore.of.isLogin)
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
              item.knowledgeIndexDtoList?.length ?? 0,
              (index) {
                final childItem = item.knowledgeIndexDtoList![index];
                final isCompleted = childItem.status == 1;
                return GestureDetector(
                  onTap: () => onSelectItem?.call(index),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: childItem.isSelected == true
                          ? ColorStyle.c557BF6
                          : isCompleted
                              ? '#557BF6'.hexColor.withOpacity(0.1)
                              : '#333333'.hexColor.withOpacity(0.1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: childItem.isSelected == true
                            ? Colors.white
                            : isCompleted
                                ? '#557BF6'.hexColor
                                : '#333333'.hexColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
