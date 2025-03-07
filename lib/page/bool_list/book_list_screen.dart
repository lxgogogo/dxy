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
import '../../widget/common_app_bar.dart';
import '../../widget/item_book.dart';
import '../../widget/three_d_book_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
/**
 * Created on 2025/3/6
 * Description:
 */
class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar.arrowBack(
        context,
        title: '',
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.search);
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              child: SvgPicture.asset(
                Assets.svg.iconSearch,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ],
      ),
      body: GetBuilder<BookListController>(
        init: BookListController(),
        builder: (controller) => _buildContent(controller),
      ),
    );
  }
}

Widget _buildContent(BookListController controller) {
  return Column(
    children: [
      Expanded(
          child: Stack(
        children: [
          SizedBox(
            height: 272.w,
            child: Image.asset(
              Assets.images.bookBanner.path,
              fit: BoxFit.cover,
            ),
          ),
          NestedScrollView(
              controller: controller.scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
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
                      onLoading: controller.onLoading,
                      child: controller.isLoaded
                          ? _buildContentView(controller)
                          : const SizedBox(),
                    ),
                  ),
                ),
              )),
        ],
      )),
    ],
  );
}

_buildContentView(BookListController controller) {
  return CustomScrollView(
    physics: const NeverScrollableScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.w,top: 22.w),
          child: Row(
            children: [
              Text(
                '好书推荐',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
              SizedBox(width: 6.w,),
              SvgPicture.asset(
                Assets.svg.homeTag,
                width: 34.w,
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 450,
          margin: EdgeInsets.only(left: 16.w, right: 16.w),
          child: PageView.builder(
            physics: const ClampingScrollPhysics(),
            controller: controller.pageController,
            itemCount: controller.bookItems.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final itemWidth = (constraints.maxWidth - 12.w) / 2;
                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 12.w,
                    children: controller.bookItems[index]
                        .map(
                          (e) => ThreeDBookItem(
                        itemWidth: itemWidth,
                        item: e,
                      ),
                    )
                        .toList(),
                  );
                },
              );
            },
          ),
        )
      ),

      SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(top: 20.w),
          child: Center(
            child: SmoothPageIndicator(
              controller: controller.pageController,
              count: controller.bookItems.length,
              effect:  ExpandingDotsEffect(
                dotHeight: 8.w,
                dotWidth: 8.w,
                activeDotColor: '#6591FF'.hexColor
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.w,top: 22.w),
          child: Row(
            children: [
              Text(
                '更多推荐',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
      SliverList(delegate: SliverChildBuilderDelegate(
        childCount: controller.articles.length,
            (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.w),
            child: BookItem(
              article: controller.articles[index],
            ),
          );

      },))
    ],
  );
}
