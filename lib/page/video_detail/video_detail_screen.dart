import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:lottie/lottie.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

import '../../widget/background_container.dart';

part 'video_detail_controller.dart';

class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoDetailController>(
      init: VideoDetailController(),
      global: false,
      builder: (controller) {
        return BackgroundContainer(
          child: Scaffold(
            appBar: CommonAppBar.arrowBack(
              context,
              title: '详情',
            ),
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18.w, 8.w, 18.w, 124.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.articleDetailBean?.title ?? '',
                    style: TextStyle(
                      color: const Color(0xff2c2c2c),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.playVideo,
                    child: Container(
                      height: 180.w,
                      margin: EdgeInsets.symmetric(vertical: 16.w),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffa2b9d0).withOpacity(0.64),
                            offset: Offset(0, 1.w),
                            blurRadius: 2.r,
                            spreadRadius: -1.w,
                          ),
                          BoxShadow(
                            color: const Color(0xffffffff),
                            offset: Offset(0, -1.w),
                            blurRadius: 2.r,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: controller.loaded && controller.chewieController != null
                          ? Chewie(
                              controller: controller.chewieController!,
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: controller.articleDetailBean?.cover ?? '',
                                  placeholder: (context, url) => const SizedBox(),
                                  errorWidget: (context, url, error) => Image.asset(
                                    'assets/images/image_loading_def.png',
                                  ),
                                ),
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Text(
                    controller.articleDetailBean?.description ?? '',
                    style: TextStyle(
                      color: const Color(0xff2a2a2a),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.w),
                  if (controller.articleDetailBean?.tagList?.isNotEmpty == true)
                    TagListView(tagList: controller.articleDetailBean?.tagList ?? []),
                  if (controller.articleDetailBean?.videoList?.isNotEmpty == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                          decoration: BoxDecoration(
                            color: '#D8E2ED'.hexColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.articleDetailBean!.videoList![controller.playVideoIndex].title ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: '#2a2a2a'.hexColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Image.asset(
                                Assets.images.collection.path,
                                width: 12.w,
                                height: 12.w,
                                color: '#2a2a2a'.hexColor,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${controller.playVideoIndex + 1}/${controller.articleDetailBean!.videoList!.length}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: '#2a2a2a'.hexColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.w),
                        SizedBox(
                          height: 48.w,
                          child: ListView.separated(
                            controller: controller.autoScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.articleDetailBean!.videoList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final video = controller.articleDetailBean!.videoList![index];
                              final isSelected = controller.playVideoIndex == index;
                              return AutoScrollTag(
                                key: ValueKey(index),
                                controller: controller.autoScrollController,
                                index: index,
                                child: GestureDetector(
                                  onTap: () => controller.selectVide(index),
                                  child: Container(
                                    width: 148.w,
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: isSelected ? '#008EFF'.hexColor.withOpacity(0.1) : '#D8E2ED'.hexColor,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        if (isSelected)
                                          Lottie.asset(
                                            'assets/lottie/play_video.json',
                                            width: 24.w,
                                            height: 24.w,
                                            repeat: true,
                                          ),
                                        Expanded(
                                          child: Text(
                                            video.title ?? '',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: isSelected ? '#008EFF'.hexColor : '#9CACC9'.hexColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, int index) => SizedBox(width: 8.w),
                          ),
                        ),
                        SizedBox(height: 16.w),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '评论(${controller.articleDetailBean?.commentCount?.abbreviateNumber ?? '0'})',
                        style: TextStyle(
                          color: const Color(0xff2a2a2a),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10.w),
                      if (controller.comments == null)
                        const SizedBox()
                      else if (controller.comments?.isNotEmpty == true)
                        ...List.generate(controller.comments!.length, (index) {
                          return CommentItem(commentBean: controller.comments![index]);
                        })
                      else
                        const Center(
                          child: NoDataView(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            bottomSheet: controller.articleDetailBean != null
                ? FeedDetailBottomView(
                    viewParams: PostBottomViewParams(
                      postId: controller.id,
                      relId: controller.id,
                      relType: NetRequest.COMMENT_TYPE_CONTENT,
                      favoriteState: controller.articleDetailBean?.favorited ?? false,
                      liked: controller.articleDetailBean?.liked ?? false,
                      shareLink: 'details/video-${controller.id}',
                      likeCount: controller.articleDetailBean?.likeCount ?? 0,
                      favoriteCount: controller.articleDetailBean?.favoriteCount ?? 0,
                      commentCount: controller.articleDetailBean?.commentCount ?? 0,
                      shareCount: controller.articleDetailBean?.shareCount ?? 0,
                    ),
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }
}
