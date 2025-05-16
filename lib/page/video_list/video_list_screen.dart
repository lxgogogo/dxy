import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/video_list/video_list_controller.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_pages.dart';
import '../../utils/track_utils.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/item_video.dart';
import '../../widget/no_data.dart';

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
      body: GetBuilder<VideoListController>(
        init: VideoListController(),
        builder: (controller) {
          return Column(
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
                    Assets.images.videoBanner.image(
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
                                onLoading: controller.onLoading,
                                child: controller.isLoaded ? _buildVideoView(controller) : const SizedBox(),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoView(VideoListController controller) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        if (controller.articles.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final int firstIndex = index * 2;
                  final int secondIndex = firstIndex + 1;
                  final bool hasSecond = secondIndex < controller.articles.length;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: VideoItem(
                            onTap: () => TrackUtils.trackEvent(userLogType: '102001', params: controller.articles[firstIndex].id),
                            item: controller.articles[firstIndex],
                          ),
                        ),
                        if (hasSecond) ...[
                          SizedBox(width: 11.w),
                          Expanded(
                            child: VideoItem(
                              onTap: () => TrackUtils.trackEvent(userLogType: '102001', params: controller.articles[secondIndex].id),
                              item: controller.articles[secondIndex],
                            ),
                          ),
                        ] else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  );
                },
                childCount: (controller.articles.length / 2).ceil(),
              ),
            ),
          )
        else
          const SliverToBoxAdapter(
            child: NoDataView(),
          ),
      ],
    );
  }
}
