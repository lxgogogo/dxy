import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/track_utils.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/course.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/item_course.dart';

part 'course_controller.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourseController>(
      init: CourseController(),
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: '',
            actions: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.search);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: SvgPicture.asset(
                    Assets.svg.iconSearch,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              Assets.images.courseBanner.image(
                height: 234.w,
              ),
              NestedScrollView(
                controller: controller.scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 211.w,
                      ),
                    )
                  ];
                },
                body: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(controller.isShowHomeMenu ? 0 : 12.r),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: '#F3F8FF'.hexColor.withOpacity(0.7),
                      ),
                      child: SmartRefresher(
                        enablePullDown: false,
                        enablePullUp: true,
                        controller: controller.refreshController,
                        onRefresh: controller.onRefresh,
                        onLoading: controller.onLoading,
                        child: CustomScrollView(
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 4.w,
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: SimpleHeaderDelegate(
                                height: 56.w,
                                builder: (_, double offset) => ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                    child: Container(
                                      color: controller.isShowHomeMenu ? '#F3F8FF'.hexColor : Colors.transparent,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 32.w,
                                              margin: EdgeInsets.symmetric(vertical: 12.w),
                                              child: Row(
                                                children: [
                                                  ...List.generate(
                                                    controller.categories.length,
                                                    (index) {
                                                      return GestureDetector(
                                                        onTap: TrackUtils.trackedTap(
                                                          onTap: () => controller.onTapTab(index),
                                                          userLogType: '104001',
                                                          params: controller.categories[index].id,
                                                        ),
                                                        child: Container(
                                                          margin: EdgeInsets.only(right: 12.w),
                                                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                                                          alignment: Alignment.centerLeft,
                                                          decoration: controller.categorySel == index
                                                              ? BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(50.r),
                                                                  gradient: const LinearGradient(
                                                                    colors: [
                                                                      Color(0xFF84BCF9),
                                                                      Color(0xFF557BF6),
                                                                    ],
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: '#0050FF'.hexColor.withOpacity(0.2),
                                                                      offset: Offset(0, 6.w),
                                                                      blurRadius: 12.r,
                                                                    ),
                                                                  ],
                                                                )
                                                              : BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(50.r),
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors.white,
                                                                      Colors.white.withOpacity(0.5),
                                                                    ],
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: '#0050FF'.hexColor.withOpacity(0.1),
                                                                      offset: Offset(0, 3.27.w),
                                                                      blurRadius: 6.54.r,
                                                                    ),
                                                                  ],
                                                                ),
                                                          child: Text(
                                                            controller.categories[index].name ?? '',
                                                            style: TextStyle(
                                                              color: controller.categorySel == index
                                                                  ? Colors.white
                                                                  : '#333333'.hexColor.withOpacity(0.7),
                                                              fontSize: 12.sp,
                                                              fontWeight: controller.categorySel == index
                                                                  ? FontWeight.w600
                                                                  : FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 12.w,
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  CourseBean bean = controller.courses[index];
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    margin: EdgeInsets.only(bottom: 18.w),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4.w,
                                              height: 16.w,
                                              margin: EdgeInsets.only(right: 6.w),
                                              decoration: BoxDecoration(
                                                  color: '#557BF6'.hexColor,
                                                  borderRadius: BorderRadius.circular(100.r)),
                                            ),
                                            Text(
                                              bean.heading!,
                                              style: TextStyle(
                                                color: '#333333'.hexColor,
                                                fontSize: 18.sp,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 12.w),
                                        CourseItem(article: bean)
                                      ],
                                    ),
                                  );
                                },
                                childCount: controller.courses.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).scrollToTopWrapper(
                controller.scrollController,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SimpleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget Function(BuildContext context, double offset) builder;

  SimpleHeaderDelegate({required this.height, required this.builder});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      builder(context, shrinkOffset);

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SimpleHeaderDelegate oldDelegate) => true;
}
