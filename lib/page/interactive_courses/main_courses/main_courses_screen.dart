import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/common_image.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../gen/assets.gen.dart';
import '../../../mixins/refresh_controller_mixin.dart';
import '../../../model/course_group_model.dart';
import '../../../model/course_model.dart';
import '../../../model/course_top_model.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes_utils.dart';
import '../../../stores/storage.dart';
import '../../../stores/user_store.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/log_util.dart';
import '../../../utils/dialog_util.dart';
import '../../../widget/common_operations_sheet.dart';
import '../../../widget/common_refresher.dart';
import '../../../widget/no_data.dart';
import '../../home/home_screen.dart';
import 'widgets/course_all_item.dart';
import 'widgets/course_challenge_alert.dart';
import 'widgets/course_challenge_item.dart';
import 'widgets/course_knowledge_item.dart';
import 'widgets/course_practice_item.dart';
import 'widgets/courses_info_view.dart';
import 'widgets/not_login_course_all_item.dart';

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
        child: Obx(() {
          if (controller.isLogin.value) {
            return Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 56.w,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().statusBarHeight, bottom: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Assets.images.logoText.image(width: 91.75.w),
                          const Spacer(),
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
                                  switch (controller
                                      .courseTopModel.value?.winningStatus) {
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
                      ),
                    ),
                    Expanded(
                      child: NestedScrollView(
                        controller: controller.scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            if (controller.isLogin.value)
                              SliverToBoxAdapter(
                                  child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.w),
                                child: CourseInfoView(),
                              ))
                          ];
                        },
                        body: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 6.w),
                              _buildSelectGroupWidget(),
                              SizedBox(height: 16.w),
                              Expanded(
                                child: Obx(
                                  () {
                                    if (!controller.hasLoaded.value) {
                                      return const CupertinoActivityIndicator(color: Colors.grey);
                                    }
                                    if (controller.courseItems.isEmpty) {
                                      return const Center(child: NoDataView());
                                    }
                                    final des = controller
                                        .courseGroup.value?.value?.des;
                                    return switch (des) {
                                      'knowledge' => CommonRefresher(
                                          controller:
                                              controller.refreshController,
                                          onLoading: controller.onLoading,
                                          enablePullDown: false,
                                          enablePullUp: controller
                                                      .courseItems.isNotEmpty ==
                                                  true ||
                                              !controller.noMore,
                                          isLoading: controller.isLoading,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                controller.courseItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item =
                                                  controller.courseItems[index];
                                              return GestureDetector(
                                                onTap: () => controller
                                                    .toKnowledge(item),
                                                child: CourseKnowledgeItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.w),
                                          ),
                                        ),
                                      'challenge' => CommonRefresher(
                                          controller:
                                              controller.refreshController,
                                          onLoading: controller.onLoading,
                                          enablePullDown: false,
                                          enablePullUp: controller
                                                      .courseItems.isNotEmpty ==
                                                  true ||
                                              !controller.noMore,
                                          isLoading: controller.isLoading,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                controller.courseItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item =
                                                  controller.courseItems[index];
                                              return GestureDetector(
                                                onTap: () => controller
                                                    .toChallenge(item),
                                                child: CourseChallengeItem(
                                                  item: item,
                                                  onTap: (value1, value2) {
                                                    controller.toChallengeItem(
                                                        value1, value2);
                                                  },
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.w),
                                          ),
                                        ),
                                      'practise' => CommonRefresher(
                                          controller:
                                              controller.refreshController,
                                          onLoading: controller.onLoading,
                                          enablePullDown: false,
                                          enablePullUp: controller
                                                      .courseItems.isNotEmpty ==
                                                  true ||
                                              !controller.noMore,
                                          isLoading: controller.isLoading,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                controller.courseItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item =
                                                  controller.courseItems[index];
                                              return GestureDetector(
                                                onTap: () =>
                                                    controller.toPractice(item),
                                                child: CoursePracticeItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.w),
                                          ),
                                        ),
                                      _ => CommonRefresher(
                                          controller:
                                              controller.refreshController,
                                          onLoading: controller.onLoading,
                                          enablePullDown: false,
                                          enablePullUp: controller
                                                      .courseItems.isNotEmpty ==
                                                  true ||
                                              !controller.noMore,
                                          isLoading: controller.isLoading,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                controller.courseItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item =
                                                  controller.courseItems[index];
                                              return GestureDetector(
                                                onTap: () => controller
                                                    .toCourseDetail(item),
                                                child: CourseAllItem(
                                                  item: item,
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.w),
                                          ),
                                        ),
                                    };
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).scrollToTopWrapper(
                        bottom: 30.w,
                        controller.scrollController,
                      ),
                    ),
                  ],
                ));
          }
          return _notLoginPage();
        }));
  }

  Widget _notLoginPage() {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 56.w,
                margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Assets.images.logoText.image(width: 91.75.w),
                    SizedBox(width: 91.75.w)
                  ],
                ),
              ),
              _buildSelectGroupWidget(),
              SizedBox(height: 16.w),
              Expanded(
                child: Obx(
                  () {
                    if (!controller.hasLoaded.value) {
                      return const CupertinoActivityIndicator(color: Colors.grey);
                    }
                    if (controller.courseItems.isEmpty) {
                      return const Center(child: NoDataView());
                    }
                    final des = controller.courseGroup.value?.value?.des;
                    return switch (des) {
                      'knowledge' => const SizedBox(),
                      'challenge' => const SizedBox(),
                      'practise' => const SizedBox(),
                      _ => CommonRefresher(
                          controller: controller.refreshController,
                          onLoading: controller.onLoading,
                          enablePullDown: false,
                          enablePullUp:
                              controller.courseItems.isNotEmpty == true ||
                                  !controller.noMore,
                          isLoading: controller.isLoading,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: controller.courseItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = controller.courseItems[index];
                              return GestureDetector(
                                onTap: () => controller.toCourseDetail(item),
                                child: NotLoginCourseAllItem(
                                  item: item,
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => SizedBox(height: 12.w),
                          ),
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSelectGroupWidget() {
    return GestureDetector(
        onTap: _onSelectCourse,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 58.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.w)),
            boxShadow: [
              BoxShadow(
                color: '#0050FF'.hexColor.withOpacity(0.1),
                blurRadius: 8.63.w,
                offset: Offset(0, 4.32.w),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
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
              ),
              Transform.rotate(
                angle: controller.showAlert.value ? pi : 0, // 180度，使用弧度制
                child: SvgPicture.asset(
                  Assets.svg.iconArrowDown,
                  width: 20.w,
                  height: 20.w,
                  color: '#666666'.hexColor,
                ),
              )
            ],
          ),
        ));
  }

  void _onSelectCourse() {
    controller.showAlert.value = !controller.showAlert.value;
    int? selectedIndex;
    if (controller.courseGroup.value != null) {
      selectedIndex = controller.courseGroups.indexWhere(
        (e) => e.value?.des == controller.courseGroup.value!.value?.des,
      );
    }
    showCommonOperationsSheet(
        maxHeight: 478.w,
        selectedIndex: selectedIndex,
        items: controller.courseGroups.map((e) => e.label ?? '').toList(),
        onSelectItem: (int index) {
          if (controller.isLogin.value) {
            final model = controller.courseGroups[index];
            controller.onChangeType(model);
          }
        },
        endAction: () {
          controller.showAlert.value = false;
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
                    color: selectedIndex == index
                        ? ColorStyle.c333333
                        : AppTheme.color_666666,
                    fontWeight: selectedIndex == index
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        overflowWidget: !controller.isLogin.value
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
            )
        ) : null);
  }

  @override
  void dispose() {
    Get.delete<MainCoursesController>();
    super.dispose();
  }
}
