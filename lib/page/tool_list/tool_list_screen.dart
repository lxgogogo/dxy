import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
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
      backgroundColor: Colors.white,
      appBar: CommonAppBar.arrowBack(
        context,
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
      body: GetBuilder<ToolListController>(
        init: ToolListController(),
        builder: (controller) => Stack(
          children: [
            SizedBox(
              height: 234.w,
              child: Image.asset(
                Assets.images.toolBanner.path,
                fit: BoxFit.cover,
              ),
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  slivers: [
                                    SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                      childCount: controller.articles.length,
                                      (context, index) {
                                        return Container(
                                          margin: EdgeInsets.fromLTRB(12.w, index == 0 ? 24.w : 8.w, 12.w, 0),
                                          child: ToolItem(
                                            article: controller.articles[index],
                                          ),
                                        );
                                      },
                                    ))
                                  ],
                                )
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
    );
  }
}
