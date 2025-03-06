import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/video_list/video_list_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_pages.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/item_video.dart';
import '../../widget/no_data.dart';

/**
 * Created on 2025/3/6
 * Description:
 */
class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: GetBuilder<VideoListController>(
        init: VideoListController(),
        builder: (controller) {
          return _buildContent(controller);
        },
      ),
    );
  }

  Widget _buildContent(VideoListController controller) {
    return Stack(
      children: [
        SizedBox(
          height: 272.w,
          child: Image.asset(
            Assets.images.banner.path,
            fit: BoxFit.cover,
          ),
        ),
        NestedScrollView(
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
                top: Radius.circular( 12.r),
              ),
             child: BackdropFilter(
               filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
               child:AnimatedContainer(
                 duration: const Duration(milliseconds: 100),
                 decoration: BoxDecoration(
                   color: '#F3F8FF'.hexColor.withOpacity(0.7),
                 ),
               ) ,
             ),
            )),
        SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: controller.refreshController,
          onLoading: controller.onLoading,
          child: controller.isLoaded
              ? _buildVideoView(controller)
              : const SizedBox(),
        )

      ],
    );
  }

 Widget _buildVideoView(VideoListController controller) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 215.w,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.w),
            child: controller.articles.isNotEmpty
                ? LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints constraints) {
                final itemWidth = (constraints.maxWidth - 12.w) / 2;
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 12.w,
                  children: controller.articles
                      .map((e) => SizedBox(
                    width: itemWidth,
                    child: VideoItem(item: e),
                  ))
                      .toList(),
                );
              },
            )
                : const NoDataView(),
          )
        ),
      ],
    );

 }
}
