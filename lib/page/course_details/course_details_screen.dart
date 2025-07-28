import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../model/course_model.dart';
import '../../routes/app_pages.dart';
import '../../routes/app_routes_utils.dart';
import '../../services/course_service.dart';
import '../../utils/dialog_util.dart';
import '../../utils/log_util.dart';
import '../../widget/dialog_common.dart';
import '../../widget/no_network.dart';
import '../interactive_courses/main_courses/widgets/course_challenge_alert.dart';
import 'widgets/course_all_item.dart';
import 'widgets/course_challenge_item.dart';
import 'widgets/course_exercises_widget.dart';
import 'widgets/course_knowledge_item.dart';

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
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: controller.detailBean?.title ?? '',
          ),
          backgroundColor: '#F7F8FC'.hexColor,
          body: controller.noNetwork
              ? NoNetworkView(
                  onRefresh: controller.refreshData,
                )
              : controller.detailBean == null
                  ? const SizedBox()
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: CourseDetailAllItem(
                                item: controller.detailBean!,
                                onTap: () => controller.onStartCourse(context),
                              ),
                            ),
                            if (controller.detailBean!.knowledge != null)
                              SliverPadding(
                                padding: EdgeInsets.only(top: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: CourseDetailKnowledgeItem(
                                    item: controller.detailBean!.knowledge!,
                                    onTap: controller.toKnowledge,
                                    onSelectItem: controller.onSelectKnowledgeItem,
                                  ),
                                ),
                              ),
                            if (controller.detailBean != null && controller.detailBean?.practise != null)
                              SliverPadding(
                                padding: EdgeInsets.only(top: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: CourseExercisesWidget(
                                    item: controller.detailBean!.practise!,
                                  ),
                                ),
                              ),
                            if (controller.detailBean!.challenge != null)
                              SliverPadding(
                                padding: EdgeInsets.only(top: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: CourseDetailChallengeItem(
                                      item: controller.detailBean!.challenge!,
                                      onTap: controller.toChallenge,
                                      itemOnTap: (value1, value2) {
                                        controller.toChallengeItem(value1, value2);
                                      }),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: 16.w),
                            )
                          ],
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
