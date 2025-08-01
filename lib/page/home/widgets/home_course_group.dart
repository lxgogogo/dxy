import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../stores/user_store.dart';
import '../../../widget/common_image.dart';
import '../../../widget/common_operations_sheet.dart';
import '../../../widget/no_data.dart';
import '../../course_details/widgets/course_exercises_widget.dart';
import '../../interactive_courses/main_courses/widgets/course_all_item.dart';
import '../../interactive_courses/main_courses/widgets/course_challenge_item.dart';
import '../../interactive_courses/main_courses/widgets/course_knowledge_item.dart';
import '../home_screen.dart';

class HomeCourseGroup extends StatelessWidget {
  const HomeCourseGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.courseGroup?.value == null) {
          return const SizedBox();
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.w),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _onSelectCourse(controller),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.courseGroup?.label ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 18.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Transform.rotate(
                      angle: controller.showAlert ? pi : 0, // 180度，使用弧度制
                      child: SvgPicture.asset(
                        Assets.svg.iconArrowDown,
                        width: 20.w,
                        height: 20.w,
                        color: '#666666'.hexColor,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              if (controller.courseItems.isEmpty)
                const Center(child: NoDataView())
              else
                Column(
                  spacing: 12.w,
                  children: List.generate(controller.courseItems.length, (index) {
                    final item = controller.courseItems[index];
                    return switch (controller.courseGroup?.value?.des) {
                      'knowledge' => CourseKnowledgeItem(
                          item: item,
                          onTapDetail: ({Duration? duration}) => controller.toKnowledge(
                            item,
                            duration: duration,
                          ),
                          onVideoComplete: () => controller.onKnowledgeVideoComplete(index),
                          onSelectItem: (int childIndex) => controller.onSelectKnowledgeItem(
                            controller.courseItems.indexOf(item),
                            childIndex,
                          ),
                        ),
                      'challenge' => GestureDetector(
                          onTap: () => controller.toChallenge(item),
                          child: CourseChallengeItem(
                            item: item,
                            onTap: (value1, value2) {
                              controller.toChallengeItem(value1, value2);
                            },
                          ),
                        ),
                      'practise' => CourseExercisesWidget(
                          pageType: 2,
                          item: item,
                          endFunction: (value) {
                            controller.endFunction(value);
                          }),
                      _ => GestureDetector(
                          onTap: () => controller.toCourseDetail(item),
                          child: CourseAllItem(
                            item: item,
                          ),
                        ),
                    };
                  }),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onSelectCourse(HomeController controller) {
    controller.showAlert = true;
    controller.safeUpdate();

    int? selectedIndex;
    if (controller.courseGroup != null) {
      selectedIndex = controller.courseGroups.indexWhere(
        (e) => e.value?.des == controller.courseGroup!.value?.des,
      );
    }
    showCommonOperationsSheet(
        maxHeight: 478.w,
        selectedIndex: selectedIndex,
        items: controller.courseGroups.map((e) => e.label ?? '').toList(),
        onSelectItem: (int index) {
          final model = controller.courseGroups[index];
          controller.onChangeType(model);
        },
        endAction: () {
          controller.showAlert = false;
          controller.safeUpdate();
        },
        itemBuilder: (int index, bool hasSelected) {
          final item = controller.courseGroups[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.value?.icon?.isNotEmpty == true)
                CommonImage.net(
                  imageUrl: item.value?.icon ?? '',
                  width: 16.w,
                  height: 16.w,
                ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  item.label ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: selectedIndex == index ? '#333333'.hexColor : '#666666'.hexColor,
                    fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        overflowWidget: !UserStore.of.isLogin
            ? Container(
                width: 1.sw,
                height: 478.w - 60.w,
                margin: EdgeInsets.only(top: 60.w),
                color: Colors.white.withOpacity(0.9),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/courses/icon_courses_not_login.png',
                  width: 128.w,
                  fit: BoxFit.cover,
                ))
            : null);
  }
}
