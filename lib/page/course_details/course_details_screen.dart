import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_all_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_challenge_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_knowledge_item.dart';
import 'package:holdem/page/interactive_courses/main_courses/widgets/course_practice_item.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../gen/assets.gen.dart';
import '../../model/course_model.dart';
import '../../routes/app_pages.dart';
import '../../services/course_service.dart';
import '../../utils/log_util.dart';
import '../../utils/toast_utils.dart';
import '../../widget/no_network.dart';

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
    return GetBuilder<CourseDetailsController>(
      init: CourseDetailsController(),
      tag: '${Get.arguments}',
      builder: (controller) {
        return FocusDetector(
          onFocusGained: controller.onFocusGained,
          child: Scaffold(
            appBar: CommonAppBar.arrowBack(
              context,
              title: controller.detailBean?.title ?? '',
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
                      '${controller.detailBean?.integral ?? 0}',
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
            body: controller.noNetwork
                ? NoNetworkView(
                    onRefresh: controller.refreshData,
                  )
                : controller.detailBean == null
                    ? const SizedBox()
                    : SafeArea(
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
                                item: controller.detailBean!,
                                onTap: () => controller.onStartCourse(),
                              ),
                              if (controller.detailBean!.knowledge != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 16.w),
                                  child: CourseKnowledgeItem(
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
                                    item: controller.detailBean!.knowledge!,
                                    onTap: controller.toKnowledge,
                                  ),
                                ),
                              if (controller.detailBean!.practise != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 16.w),
                                  child: CoursePracticeItem(
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
                                    item: controller.detailBean!.practise!,
                                    onTap: controller.toPractice,
                                  ),
                                ),
                              if (controller.detailBean!.challenge != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 16.w),
                                  child: CourseChallengeItem(
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
                                    item: controller.detailBean!.challenge!,
                                    onTap: controller.toChallenge,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    Get.delete<CourseDetailsController>();
    super.dispose();
  }
}
