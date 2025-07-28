import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../stores/user_store.dart';
import '../../../widget/common_image.dart';
import '../../../widget/common_operations_sheet.dart';
import '../../course_details/widgets/course_knowledge_item.dart';
import '../../interactive_courses/main_courses/widgets/course_all_item.dart';
import '../../interactive_courses/main_courses/widgets/course_challenge_item.dart';
import '../../interactive_courses/main_courses/widgets/course_knowledge_item.dart';
import '../../interactive_courses/main_courses/widgets/course_practice_item.dart';
import '../home_screen.dart';

class HomeCourseGroup extends StatelessWidget {
  const HomeCourseGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.w),
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Column(
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
                    SvgPicture.asset(
                      Assets.svg.iconArrowDown,
                      width: 20.w,
                      height: 20.w,
                      color: '#666666'.hexColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Column(
                spacing: 12.w,
                children: controller.courseItems.map(
                  (item) {
                    final des = controller.courseGroup?.value?.des;
                    return switch (des) {
                      'knowledge' => CourseDetailKnowledgeItem(
                          item: item,
                          onTap: () => controller.toKnowledge(item),
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
                      'practise' => GestureDetector(
                          onTap: () => controller.toPractice(item),
                          child: CoursePracticeItem(
                            item: item,
                          ),
                        ),
                      _ => GestureDetector(
                          onTap: () => controller.toCourseDetail(item),
                          child: CourseAllItem(
                            item: item,
                          ),
                        ),
                    };
                  },
                ).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSelectCourse(HomeController controller) {
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
        itemBuilder: (int index) {
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
                    fontWeight: selectedIndex == index ? FontWeight.w500 : FontWeight.w400,
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
