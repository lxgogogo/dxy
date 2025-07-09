import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

import '../../utils/track_utils.dart';
import 'widgets/video_child_list_sheet.dart';

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
            // appBar: CommonAppBar.arrowBack(
            //   context,
            //   title: '详情',
            // ),
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: controller.noNetwork
                ? NoNetworkView(
                    onRefresh: controller.refreshData,
                  )
                : controller.detailBean == null
                    ? const SizedBox()
                    : Padding(
                        padding: EdgeInsets.only(bottom: 90.w),
                        child: SmartRefresher(
                          enablePullDown: false,
                          enablePullUp: controller.comments?.isNotEmpty == true || !controller.noMore,
                          controller: controller.refreshController,
                          onLoading: controller.onLoading,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: GestureDetector(
                                  onTap: controller.playVideo,
                                  child: Container(
                                      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                                      color: Colors.black,
                                      child: SizedBox(
                                        height: 200.w,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Obx(() {
                                              if (!controller.haveWatchPower.value) {
                                                return CachedNetworkImage(
                                                  imageUrl: controller.detailBean?.cover ?? '',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                                  errorWidget: (context, url, error) =>
                                                      Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                                );
                                              }
                                              return controller.videoNotifier.chewieController != null
                                                  ? ChewieVideo(
                                                      notifier: controller.videoNotifier,
                                                    )
                                                  : const Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                            }),
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: Get.back,
                                                behavior: HitTestBehavior.opaque,
                                                child: Container(
                                                  height: kToolbarHeight,
                                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                                  child: SvgPicture.asset(
                                                    Assets.svg.iconBack,
                                                    width: 24.w,
                                                    height: 24.w,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 16.w),
                                      Text(
                                        controller.detailBean?.title ?? '',
                                        style: TextStyle(
                                          color: '#333333'.hexColor,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12.w),
                                      Text(
                                        controller.detailBean?.description ?? '',
                                        style: TextStyle(
                                          color: '#333333'.hexColor,
                                          fontSize: 16.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                            GestureDetector(
                                              onTap: () {
                                                if (!controller.haveWatchPower.value) {
                                                  return;
                                                }
                                                showVideoChildListSheet(
                                                  items: controller.detailBean!.videoList!,
                                                  selectedIndex: controller.playVideoIndex,
                                                  onSelectItem: (int index) {
                                                    controller.selectVide(index);
                                                    TrackUtils.trackEvent(
                                                      userLogType: '103001',
                                                      params: controller.detailBean!.videoList![index].id,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                                                decoration: BoxDecoration(
                                                  color: '#333333'.hexColor.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '合集 · ${controller.detailBean!.videoList![controller.playVideoIndex].title}',
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: '#333333'.hexColor,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Lottie.asset(
                                                      Assets.lottie.playVideoGrey,
                                                      width: 16.w,
                                                      repeat: true,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                      child: Text(
                                                        '${controller.playVideoIndex + 1}/${controller.detailBean!.videoList!.length}',
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: '#999999'.hexColor,
                                                        ),
                                                      ),
                                                    ),
                                                    SvgPicture.asset(
                                                      Assets.svg.iconArrowRight,
                                                      width: 16.w,
                                                      height: 16.w,
                                                      color: '#999999'.hexColor,
                                                    ),
                                                  ],
                                                ),
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
                              ),
                              if (controller.comments == null)
                                const SliverToBoxAdapter()
                              else if (controller.comments?.isNotEmpty == true)
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return CommentItem(
                                        commentBean: controller.comments![index],
                                        sourceType: SourceType.video,
                                        sourceId: controller.id,
                                      );
                                    },
                                    childCount: controller.comments!.length,
                                  )),
                                )
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

  void initChewieController(videoPlayerController, Function fullScreenCallBack) {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      showControlsOnInitialize: false,
      fullScreenCallBack: fullScreenCallBack,
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
