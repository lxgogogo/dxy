import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/routes/app_routes_utils.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

import '../../utils/track_utils.dart';

part 'video_detail_controller.dart';

class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoDetailController>(
      init: VideoDetailController(),
      // tag: '${DateTime.now().millisecondsSinceEpoch}',
      builder: (controller) {
        return FocusDetector(
          onFocusGained: controller.onFocusGained,
          onFocusLost: controller.onFocusLost,
          child: Scaffold(
            appBar: CommonAppBar.arrowBack(
              context,
              title: '详情',
            ),
            backgroundColor: Colors.white,
            extendBody: true,
            body: controller.noNetwork
                ? NoNetworkView(
                    onRefresh: controller.refreshData,
                  )
                : controller.detailBean == null
                    ? const SizedBox()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 90.w),
                        child: SmartRefresher(
                          enablePullDown: false,
                          enablePullUp: controller.comments?.isNotEmpty == true || !controller.noMore,
                          controller: controller.refreshController,
                          onLoading: controller.onLoading,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      controller.detailBean?.title ?? '',
                                      style: TextStyle(
                                        color: '#1E1E1E'.hexColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: controller.playVideo,
                                      child: Container(
                                          height: 192.w,
                                          margin: EdgeInsets.symmetric(vertical: 12.w),
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(16.r),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: const Color(0xffa2b9d0).withOpacity(0.64),
                                            //     offset: Offset(0, 1.w),
                                            //     blurRadius: 2.r,
                                            //     spreadRadius: -1.w,
                                            //   ),
                                            //   BoxShadow(
                                            //     color: const Color(0xffffffff),
                                            //     offset: Offset(0, -1.w),
                                            //     blurRadius: 2.r,
                                            //     spreadRadius: 0,
                                            //   ),
                                            // ],
                                          ),
                                          child: Obx(() {
                                            if (!controller.haveWatchPower.value) {
                                              return const SizedBox();
                                            }
                                            return controller.videoNotifier.chewieController != null
                                                ? ChewieVideo(
                                                    notifier: controller.videoNotifier,
                                                  )
                                                : const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                          })),
                                    ),
                                    Text(
                                      controller.detailBean?.description ?? '',
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    if (controller.detailBean?.tagList?.isNotEmpty == true)
                                      TagListView(
                                        tagList: controller.detailBean?.tagList ?? [],
                                        onTapItem: (model) => TrackUtils.trackEvent(
                                          userLogType: '103002',
                                          params: model.id,
                                        ),
                                      ),
                                    if (controller.detailBean?.videoList?.isNotEmpty == true)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '选集',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: '#333333'.hexColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                // Image.asset(
                                                //   Assets.images.collection.path,
                                                //   width: 12.w,
                                                //   height: 12.w,
                                                //   color: '#2a2a2a'.hexColor,
                                                // ),
                                                Text(
                                                  '正在播放',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: '#999999'.hexColor,
                                                  ),
                                                ),
                                                Text(
                                                  '【${controller.playVideoIndex + 1}】/全${controller.detailBean!.videoList!.length}集',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: '#999999'.hexColor,
                                                  ),
                                                ),
                                                SvgPicture.asset(
                                                  Assets.svg.iconArrowRight,
                                                  width: 14,
                                                  height: 14.w,
                                                  color: '#999999'.hexColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8.w),
                                          SizedBox(
                                            height: 64.w,
                                            child: ListView.separated(
                                              controller: controller.autoScrollController,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller.detailBean!.videoList!.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                final video = controller.detailBean!.videoList![index];
                                                final isSelected = controller.playVideoIndex == index;
                                                return AutoScrollTag(
                                                  key: ValueKey(index),
                                                  controller: controller.autoScrollController,
                                                  index: index,
                                                  child: GestureDetector(
                                                    onTap: TrackUtils.trackedTap(
                                                      onTap: () => controller.selectVide(index),
                                                      userLogType: '103001',
                                                      params: controller.detailBean!.videoList![index].id,
                                                    ),
                                                    child: Container(
                                                      width: 134.w,
                                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                                      decoration: BoxDecoration(
                                                        color: '#333333'.hexColor.withOpacity(0.05),
                                                        borderRadius: BorderRadius.circular(12.r),
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            if (isSelected)
                                                              WidgetSpan(
                                                                alignment: PlaceholderAlignment.middle,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(4.w),
                                                                  child: Lottie.asset(
                                                                    'assets/lottie/play_video.json',
                                                                    width: 10.w,
                                                                    repeat: true,
                                                                  ),
                                                                ),
                                                              ),
                                                            TextSpan(
                                                              text: video.title ?? '',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: isSelected
                                                                    ? '#557BF6'.hexColor
                                                                    : '#333333'.hexColor,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (_, int index) => SizedBox(width: 12.w),
                                            ),
                                          ),
                                          SizedBox(height: 24.w),
                                        ],
                                      ),
                                    Text(
                                      '评论 ${controller.detailBean?.commentCount?.abbreviateNumber ?? '0'}条',
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.w),
                                  ],
                                ),
                              ),
                              if (controller.comments == null)
                                const SliverToBoxAdapter()
                              else if (controller.comments?.isNotEmpty == true)
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return CommentItem(
                                      commentBean: controller.comments![index],
                                      sourceType: SourceType.video,
                                      sourceId: controller.id,
                                    );
                                  },
                                  childCount: controller.comments!.length,
                                ))
                              else
                                const SliverToBoxAdapter(
                                  child: NoCommentView(),
                                ),
                            ],
                          ),
                        ),
                      ),
            bottomSheet: controller.detailBean != null
                ? CommonDetailBottomView(
                    viewParams: DetailViewParams(
                      postId: controller.id,
                      relId: controller.id,
                      relType: NetRequest.COMMENT_TYPE_CONTENT,
                      favoriteState: controller.detailBean?.favorited ?? false,
                      liked: controller.detailBean?.liked ?? false,
                      shareLink: controller.shareLink,
                      likeCount: controller.detailBean?.likeCount ?? 0,
                      favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                      commentCount: controller.detailBean?.commentCount ?? 0,
                      shareCount: controller.detailBean?.shareCount ?? 0,
                    ),
                    sourceType: SourceType.video,
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }
}

class ChewieVideo extends StatelessWidget {
  final VideoNotifier _videoNotifier;

  const ChewieVideo({super.key, notifier}) : _videoNotifier = notifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _videoNotifier,
        builder: (context, child) {
          // final orientation = MediaQuery.of(context).orientation;
          // _videoNotifier.chewieController!.isFullScreen = orientation != Orientation.landscape;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: Chewie(
                controller: _videoNotifier.chewieController!,
              ),
            ),
          );
        });
  }
}

class VideoNotifier extends ChangeNotifier {
  ChewieController? _chewieController;

  ChewieController? get chewieController => _chewieController;

  void initChewieController(videoPlayerController) {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      showControlsOnInitialize: false,
      routePageBuilder: (context, animation, secondaryAnimation, controllerProvider) {
        return ChewieVideo(notifier: this);
      },
      // deviceOrientationsOnEnterFullScreen: DeviceOrientation.values,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    notifyListeners();
  }
}
