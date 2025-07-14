import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_pages.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/item_tool.dart';
import '../../widget/no_data.dart';
import 'tool_list_controller.dart';

class ToolListScreen extends StatelessWidget {
  const ToolListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: GetBuilder<ToolListController>(
        init: ToolListController(),
        builder: (controller) => Stack(
          children: [
            Assets.images.toolBanner.image(
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
                              ? CustomScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  slivers: [
                                    SliverPadding(
                                      padding: EdgeInsets.all(16.w),
                                      sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                        childCount: controller.articles.length,
                                        (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 12.w),
                                            child: ToolItem(
                                              article: controller.articles[index],
                                            ),
                                          );
                                        },
                                      )),
                                    ),
                                  ],
                                )
                              : const Center(child: NoDataView())
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
            ).scrollToTopWrapper(
              controller.scrollController,
            ),
          ],
        ),
      ),
    );
  }
}
