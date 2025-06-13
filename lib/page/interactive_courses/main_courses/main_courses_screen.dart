import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/common_image.dart';
import 'package:intl/intl.dart';

import '../../../gen/assets.gen.dart';
import '../../../mixins/refresh_controller_mixin.dart';
import '../../../model/course_group_model.dart';
import '../../../model/course_model.dart';
import '../../../model/course_top_model.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes_utils.dart';
import '../../../stores/storage.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/log_util.dart';
import '../../../utils/toast_utils.dart';
import '../../../widget/common_operations_sheet.dart';
import '../../../widget/common_refresher.dart';
import '../../../widget/no_data.dart';
import 'widgets/course_all_item.dart';
import 'widgets/course_challenge_item.dart';
import 'widgets/course_knowledge_item.dart';
import 'widgets/course_practice_item.dart';
import 'widgets/courses_info_view.dart';

part 'main_courses_binding.dart';

part 'main_courses_controller.dart';

class MainCoursesScreen extends StatefulWidget {
  const MainCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MainCoursesScreen> createState() => _MainCoursesScreenState();
}

class _MainCoursesScreenState extends State<MainCoursesScreen> {
  final MainCoursesController controller = Get.put(MainCoursesController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: controller.onFocusGained,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 56.w,
                margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Assets.images.logoText.image(width: 91.75.w),
                    const Spacer(),
                    if (controller.hasLoaded.value) ...[
                      GestureDetector(
                        onTap: controller.toWinningStreak,
                        child: Container(
                          height: 34.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: '#333333'.hexColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              switch (controller.courseTopModel.value?.winningStatus) {
                                1 => SvgPicture.asset(
                                    Assets.svg.iconWinningStatus1,
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                                2 => SvgPicture.asset(
                                    Assets.svg.iconWinningStatus2,
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                                3 => SvgPicture.asset(
                                    Assets.svg.iconWinningStatus3,
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                                _ => const SizedBox(),
                              },
                              // if ((controller.courseTopModel.value?.winningDay ?? 0) > 0) ...[
                              SizedBox(width: 8.w),
                              Text(
                                '${controller.courseTopModel.value?.winningDay ?? 0}',
                                style: TextStyle(
                                  color: '#666666'.hexColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              // ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 34.w,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: '#333333'.hexColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              Assets.svg.iconCourseIntegral,
                              width: 16.w,
                              height: 16.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${controller.courseTopModel.value?.integral ?? 0}',
                              style: TextStyle(
                                color: '#666666'.hexColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 10.w),
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                          child: CourseInfoView(),
                        ),
                      ),
                    ];
                  },
                  body: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                            Obx(() {
                              return Flexible(
                                child: Text(
                                  controller.courseGroup.value?.label ?? '',
                                  style: TextStyle(
                                    color: '#000000'.hexColor,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            GestureDetector(
                              onTap: () {
                                int? selectedIndex;
                                if (controller.courseGroup.value != null) {
                                  selectedIndex = controller.courseGroups.indexOf(controller.courseGroup.value!);
                                }
                                showCommonOperationsSheet(
                                  maxHeight: 238.w,
                                  selectedIndex: selectedIndex,
                                  items: controller.courseGroups.map((e) => e.label ?? '').toList(),
                                  onSelectItem: (int index) {
                                    controller.onChangeType(controller.courseGroups[index]);
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
                                );
                              },
                              child: Container(
                                height: 16.w,
                                margin: EdgeInsets.only(left: 8.w),
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: '#999999'.hexColor, width: 0.2.w),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '更换',
                                  style: TextStyle(
                                    color: '#666666'.hexColor,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.w),
                        Expanded(
                          child: Obx(
                            () {
                              final des = controller.courseGroup.value?.value?.des;
                              return switch (des) {
                                'knowledge' => CommonRefresher(
                                    controller: controller.refreshController,
                                    onLoading: controller.onLoading,
                                    enablePullDown: false,
                                    enablePullUp: controller.items.isNotEmpty == true || !controller.noMore,
                                    isLoading: controller.isLoading,
                                    child: controller.items.isNotEmpty
                                        ? ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount: controller.items.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final item = controller.items[index];
                                              return GestureDetector(
                                                onTap: () => controller.toKnowledge(item),
                                                child: CourseKnowledgeItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                          )
                                        : const Center(child: NoDataView()),
                                  ),
                                'challenge' => CommonRefresher(
                                    controller: controller.refreshController,
                                    onLoading: controller.onLoading,
                                    enablePullDown: false,
                                    enablePullUp: controller.items.isNotEmpty == true || !controller.noMore,
                                    isLoading: controller.isLoading,
                                    child: controller.items.isNotEmpty
                                        ? ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount: controller.items.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final item = controller.items[index];
                                              return GestureDetector(
                                                onTap: () => controller.toChallenge(item),
                                                child: CourseChallengeItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                          )
                                        : const Center(child: NoDataView()),
                                  ),
                                'practise' => CommonRefresher(
                                    controller: controller.refreshController,
                                    onLoading: controller.onLoading,
                                    enablePullDown: false,
                                    enablePullUp: controller.items.isNotEmpty == true || !controller.noMore,
                                    isLoading: controller.isLoading,
                                    child: controller.items.isNotEmpty
                                        ? ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount: controller.items.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final item = controller.items[index];
                                              return GestureDetector(
                                                onTap: () => controller.toPractice(item),
                                                child: CoursePracticeItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                          )
                                        : const Center(child: NoDataView()),
                                  ),
                                _ => CommonRefresher(
                                    controller: controller.refreshController,
                                    onLoading: controller.onLoading,
                                    enablePullDown: false,
                                    enablePullUp: controller.items.isNotEmpty == true || !controller.noMore,
                                    isLoading: controller.isLoading,
                                    child: controller.items.isNotEmpty
                                        ? ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount: controller.items.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final item = controller.items[index];
                                              return GestureDetector(
                                                onTap: () => controller.toCourseDetail(item),
                                                child: CourseAllItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                          )
                                        : const Center(child: NoDataView()),
                                  ),
                              };
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MainCoursesController>();
    super.dispose();
  }
}
