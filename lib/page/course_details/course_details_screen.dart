import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_all_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_challenge_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_knowledge_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_practice_item.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../gen/assets.gen.dart';
import '../../model/course_model.dart';

part 'course_details_binding.dart';

part 'course_details_controller.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final CourseDetailsController controller = Get.put(CourseDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.arrowBack(
        context,
        title: '课程名称最多就十个字',
        centerTitle: false,
        actions: [
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.iconCourseIntegral,
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '8888888',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
        ],
      ),
      backgroundColor: '#F7F8FC'.hexColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CourseAllItem(
                boxDecoration: BoxDecoration(
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
                item: CourseModel(),
              ),
              SizedBox(height: 16.w),
              CourseKnowledgeItem(
                boxDecoration: BoxDecoration(
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
                item: CourseModel(),
              ),
              SizedBox(height: 16.w),
              CoursePracticeItem(
                boxDecoration: BoxDecoration(
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
                item: CourseModel(),
              ),
              SizedBox(height: 16.w),
              CourseChallengeItem(
                boxDecoration: BoxDecoration(
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
                item: CourseModel(),
              ),
              SizedBox(height: 16.w),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CourseDetailsController>();
    super.dispose();
  }
}
