import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../../gen/assets.gen.dart';
import '../main_courses_screen.dart';

class CourseInfoView extends StatelessWidget {
  CourseInfoView({
    super.key,
  });

  final MainCoursesController controller = Get.find<MainCoursesController>();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '我的进度',
                style: TextStyle(
                  color: '#000000'.hexColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '完成度：${controller.courseProgress * 100}%',
                style: TextStyle(
                  color: '#666666'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: double.infinity,
              height: 4.w,
              decoration: BoxDecoration(
                color: '#333333'.hexColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: controller.courseProgress * constraints.maxWidth,
                      color: '#557BF6'.hexColor,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.w),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final itemWidth = (constraints.maxWidth - 11.w) / 2;
              return Wrap(
                spacing: 11.w,
                runSpacing: 13.w,
                children: [
                  _buildMenuItem(
                    itemWidth,
                    title: '课程',
                    content: '${controller.courseTopModel.value?.courseRemaining ?? 0}',
                    assetName: Assets.images.iconCourseAll.path,
                    backgroundColor: '#EBF5FF'.hexColor,
                  ),
                  _buildMenuItem(
                    itemWidth,
                    title: '知识',
                    content: '${controller.courseTopModel.value?.knowledgeRemaining ?? 0}',
                    assetName: Assets.images.iconCourseKnowledge.path,
                    backgroundColor: '#FEF1EC'.hexColor,
                  ),
                  _buildMenuItem(
                    itemWidth,
                    title: '练习',
                    content: '${controller.courseTopModel.value?.practiseRemaining ?? 0}',
                    assetName: Assets.images.iconCoursePractice.path,
                    backgroundColor: '#EEFFEB'.hexColor,
                  ),
                  _buildMenuItem(
                    itemWidth,
                    title: '挑战',
                    content: '${controller.courseTopModel.value?.challengeRemaining ?? 0}',
                    assetName: Assets.images.iconCourseChallenge.path,
                    backgroundColor: '#FFF7EB'.hexColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    double width, {
    required String title,
    required String content,
    required String assetName,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 150 / 64,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: '#666666'.hexColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      content,
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                assetName,
                width: 40.w,
                height: 40.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
