import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../gen/assets.gen.dart';
import '../../../mixins/refresh_controller_mixin.dart';
import '../../../model/search_top.dart';
import '../../../routes/app_pages.dart';
import '../../../services/index.dart';
import '../../../widget/common_refresher.dart';
import '../../../widget/no_data.dart';
import 'widgets/course_all_item.dart';
import 'widgets/course_challenge_item.dart';
import 'widgets/course_knowledge_item.dart';
import 'widgets/course_practice_item.dart';
import 'widgets/courses_info_view.dart';

part 'main_courses_binding.dart';

part 'main_courses_controller.dart';

enum CourseType {
  all('所有课程'),
  knowledge('我的知识'),
  challenge('我的挑战'),
  practice('我的练习');

  final String title;

  const CourseType(this.title);
}

class MainCoursesScreen extends StatefulWidget {
  const MainCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MainCoursesScreen> createState() => _MainCoursesScreenState();
}

class _MainCoursesScreenState extends State<MainCoursesScreen> {
  final MainCoursesController controller = Get.put(MainCoursesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Column(
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
                        Assets.svg.iconCourseHot,
                        width: 16.w,
                        height: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '9999',
                        style: TextStyle(
                          color: '#666666'.hexColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                        '8888888',
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
          SizedBox(height: 10.w),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                      child: const CourseInfoView(),
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
                          return Text(
                            controller.courseType.value.title,
                            style: TextStyle(
                              color: '#000000'.hexColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () => controller.onChangeType(
                            CourseType.values[Random().nextInt(CourseType.values.length)],
                          ),
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
                          return switch (controller.courseType.value) {
                            CourseType.all => CommonRefresher(
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
                                            onTap: () => controller.toCourseDetail (),
                                            child: CourseAllItem(),
                                          );
                                        },
                                        separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                      )
                                    : const Center(child: NoDataView()),
                              ),
                            CourseType.knowledge => CommonRefresher(
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
                                          return const CourseKnowledgeItem();
                                        },
                                        separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                      )
                                    : const Center(child: NoDataView()),
                              ),
                            CourseType.challenge => CommonRefresher(
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
                                          return const CourseChallengeItem();
                                        },
                                        separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                      )
                                    : const Center(child: NoDataView()),
                              ),
                            CourseType.practice => CommonRefresher(
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
                                          return const CoursePracticeItem();
                                        },
                                        separatorBuilder: (_, __) => SizedBox(height: 12.w),
                                      )
                                    : const Center(child: NoDataView()),
                              ),
                          };
                        },
                      ),
                    ),
                    SizedBox(
                      height: kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MainCoursesController>();
    super.dispose();
  }
}
