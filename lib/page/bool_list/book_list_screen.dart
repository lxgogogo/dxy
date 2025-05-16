import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/bool_list/book_list_controller.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_pages.dart';
import '../../utils/track_utils.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/item_book.dart';
import '../../widget/no_data.dart';
import '../../widget/three_d_book_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<BookListController>(
        init: BookListController(),
        builder: (controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56.w,
              margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: SvgPicture.asset(
                        Assets.svg.iconBack,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
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
            ),
            Expanded(
              child: Stack(
                children: [
                  Assets.images.bookBanner.image(
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
                            enablePullUp: controller.articles.isNotEmpty || !controller.noMore,
                            controller: controller.refreshController,
                            onLoading: controller.onLoading,
                            child: controller.isLoaded
                                ? controller.articles.isNotEmpty
                                    ? _buildContentView(controller)
                                    : const Center(child: NoDataView())
                                : const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_buildContentView(BookListController controller) {
  return CustomScrollView(
    physics: const ClampingScrollPhysics(),
    slivers: [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 12.w),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text(
                '好书推荐',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 18.sp,
                ),
              ),
              // SizedBox(
              //   width: 6.w,
              // ),
              // SvgPicture.asset(
              //   Assets.svg.homeTag,
              //   width: 34.w,
              // ),
              const Spacer(),
              GestureDetector(
                onTap: controller.loadBooks,
                child: Row(
                  children: [
                    Text(
                      '换一批',
                      style: TextStyle(
                        color: '#999999'.hexColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: controller.isSwitching ? controller.animationController.value * 2 * pi : 0,
                          child: SvgPicture.asset(
                            Assets.svg.iconRefresh,
                            width: 12.w,
                            height: 12.w,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverToBoxAdapter(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final itemWidth = (constraints.maxWidth - 11.w) / 2;
            return Wrap(
              spacing: 11.w,
              runSpacing: 16.w,
              children: controller.bookItems
                  .map(
                    (e) => ThreeDBookItem(
                      itemWidth: itemWidth,
                      item: e,
                      onTap: () {
                        TrackUtils.trackEvent(userLogType: '106001', params: e.id ?? 0);
                      },
                    ),
                  )
                  .toList(),
            );
          },
        )),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 24.w, 16.w, 12.w),
        sliver: SliverToBoxAdapter(
          child: Text(
            '更多推荐',
            style: TextStyle(
              color: '#333333'.hexColor,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: controller.articles.length,
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: BookItem(
                  article: controller.articles[index],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
