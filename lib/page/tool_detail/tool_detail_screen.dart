import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/routes/app_routes_utils.dart';
import 'package:holdem/utils/common_util.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/date_util.dart';
import '../../utils/track_utils.dart';

part 'tool_detail_controller.dart';

class ToolDetailScreen extends StatefulWidget {
  const ToolDetailScreen({super.key});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ToolDetailController>(
      init: ToolDetailController(),
      tag: '${Get.arguments}',
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: '工具详情',
          ),
          backgroundColor: Colors.white,
          extendBody: true,
          body: controller.noNetwork
              ? NoNetworkView(
                  onRefresh: controller.refreshData,
                )
              : controller.detailBean == null
                  ? const SizedBox()
                  : Column(
                      children: [
                        Expanded(
                          child: SmartRefresher(
                            scrollController: controller.scrollController,
                            enablePullDown: false,
                            enablePullUp: controller.comments?.isNotEmpty == true || !controller.noMore,
                            controller: controller.refreshController,
                            onLoading: controller.onLoading,
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: ColoredBox(
                                    color: Colors.white,
                                    child: Stack(
                                      children: [
                                        Container(
                                          color: '#D9D9D9'.hexColor.withOpacity(0.2),
                                          margin: EdgeInsets.only(top: 24.w, bottom: 110.w),
                                          alignment: Alignment.center,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: CachedNetworkImage(
                                              imageUrl: controller.detailBean?.cover ?? '',
                                              width: 188.w,
                                              height: 241.w,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                              errorWidget: (context, url, error) =>
                                                  Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(height: 241.w),
                                            ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(16.w, 24.w, 16.w, 12.w),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.white.withOpacity(0.7),
                                                        Colors.white,
                                                      ],
                                                    ),
                                                  ),
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
                                                      if (controller.detailBean?.description?.isNotEmpty == true)
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 8.w),
                                                          child: Text(
                                                            controller.detailBean?.description ?? '',
                                                            style: TextStyle(
                                                              color: '#333333'.hexColor,
                                                              fontSize: 16.sp,
                                                            ),
                                                            maxLines: 6,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      SizedBox(height: 12.w),
                                                      if (controller.detailBean?.tagList?.isNotEmpty == true)
                                                        TagListView(
                                                          tagList: controller.detailBean?.tagList ?? [],
                                                          onTapItem: (model) => TrackUtils.trackEvent(
                                                            userLogType: '107002',
                                                            params: model.id,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: GestureDetector(
                                    onTap: () {
                                      final androidUrl = controller.detailBean?.tool?.androidUrl ?? '';
                                      final iosUrl = controller.detailBean?.tool?.iosUrl ?? '';
                                      final url = controller.detailBean?.tool?.url ?? '';
                                      if (Platform.isAndroid) {
                                        launchUrlString(
                                          androidUrl.isNotEmpty
                                              ? androidUrl
                                              : url.isNotEmpty
                                                  ? url
                                                  : iosUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else if (Platform.isIOS) {
                                        launchUrlString(
                                          iosUrl.isNotEmpty
                                              ? iosUrl
                                              : url.isNotEmpty
                                                  ? url
                                                  : androidUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Container(
                                        width: 160.w,
                                        height: 46.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100.r),
                                          gradient: LinearGradient(
                                            colors: [
                                              '#557BF6'.hexColor,
                                              '#84BCF9'.hexColor,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: '#58A5FF'.hexColor.withOpacity(0.2),
                                              blurRadius: 6.r,
                                              offset: Offset(0, 12.w),
                                            )
                                          ],
                                        ),
                                        child: Text(
                                          '下载资源',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(16.w, 24.w, 16.w, 16.w),
                                    child: Text(
                                      '评论 ${controller.detailBean?.commentCount?.abbreviateNumber ?? '0'}条',
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                if (controller.comments == null)
                                  const SliverToBoxAdapter()
                                else if (controller.comments?.isNotEmpty == true)
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: CommentItem(
                                          commentsData: controller.comments ?? [],
                                          commentBean: controller.comments![index],
                                          sourceType: SourceType.tool,
                                          sourceId: controller.id,
                                          followOnTap: controller.followOnTap,
                                        ),
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
                          ).scrollToTopWrapper(
                            controller.scrollController,
                          ),
                        ),
                        SafeArea(child: SizedBox(height: 10.w))
                      ],
                    ),
          bottomNavigationBar: controller.detailBean != null
              ? CommonDetailBottomView(
                  viewParams: DetailViewParams(
                    postId: controller.id,
                    relId: controller.id,
                    relType: NetRequest.COMMENT_TYPE_CONTENT,
                    favoriteState: controller.detailBean?.favorited ?? false,
                    liked: controller.detailBean?.liked ?? false,
                    shareLink: 'details/tool-${controller.id}',
                    likeCount: controller.detailBean?.likeCount ?? 0,
                    favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                    commentCount: controller.detailBean?.commentCount ?? 0,
                    shareCount: controller.detailBean?.shareCount ?? 0,
                  ),
                  sourceType: SourceType.tool,
                )
              : const SizedBox(),
        );
      },
    );
  }
}
