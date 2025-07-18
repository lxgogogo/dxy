import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:html/dom.dart' as dom;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import '../../gen/assets.gen.dart';
import '../../mixins/stay_report_mixin.dart';
import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../services/index.dart';
import '../../stores/config_store.dart';
import '../../utils/date_util.dart';
import '../../utils/track_utils.dart';
import '../../widget/feed_more_action.dart';
import '../../widget/report_sheet.dart';
import '../search_tag/widgets/search_tag_child_view.dart';

part 'feed_detail_controller.dart';

class FeedDetailScreen extends StatelessWidget {
  const FeedDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedDetailController>(
      init: FeedDetailController(),
      tag: '${Get.arguments}',
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: '',
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: FeedMoreAction(
                  actions: {
                    '屏蔽该内容': () {
                      controller._onShield(controller.detailBean!.id!);
                    },
                    '屏蔽该用户': () {
                      controller._onShieldUser(controller.detailBean!.user!.id!);
                    },
                    '举报该内容': () {
                      controller._onReport(controller.detailBean!.id!, controller.detailBean!.user!.id!);
                    }
                  },
                ),
              ),
            ],
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
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.w),
                      child: SmartRefresher(
                        scrollController: controller.scrollController,
                        enablePullDown: false,
                        enablePullUp: controller.comments?.isNotEmpty == true || !controller.noMore,
                        controller: controller.refreshController,
                        onLoading: controller.onLoading,
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Text(
                                controller.detailBean?.title ?? '',
                                style: TextStyle(
                                  color: '#333333'.hexColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: (controller.detailBean?.sign?.contains('office') ?? false)
                                          ? Text(
                                              controller.detailBean!.createdAt != null
                                                  ? '${DateUtil.formatDateAlias3(
                                                      controller.detailBean!.createdAt?.millisecondsSinceEpoch ?? 0,
                                                      hasHM: true,
                                                    )}发布'
                                                  : '',
                                              style: TextStyle(color: '#333333'.hexColor, fontSize: 12),
                                            )
                                          : Row(
                                              children: [
                                                BorderAvatar(
                                                    avatar: controller.detailBean?.user?.avatar ?? '',
                                                    avatarSize: 20.w),
                                                SizedBox(width: 4.w),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          controller.detailBean?.user?.nickname ?? '',
                                                          style: TextStyle(
                                                            color: '#666666'.hexColor,
                                                            fontSize: 12.sp,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12.w),
                                                      Text(
                                                        controller.detailBean?.createdAt != null
                                                            ? '${DateUtil.formatDateAlias3(
                                                                controller
                                                                    .detailBean!.createdAt!.millisecondsSinceEpoch,
                                                              )}发布'
                                                            : '',
                                                        style: TextStyle(
                                                          color: '#333333'.hexColor.withOpacity(0.7),
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.detailBean?.advertiseStatus == 1)
                              SliverToBoxAdapter(
                                child: Builder(
                                  builder: (context) {
                                    if (controller.detailBean?.userlevel?.advertise == 0) return const SizedBox();
                                    final advertiseImage = controller.detailBean?.advertiseImage ?? '';
                                    if (advertiseImage.isEmpty) return const SizedBox();
                                    precacheImage(
                                      CachedNetworkImageProvider(advertiseImage, cacheKey: advertiseImage),
                                      context,
                                    );
                                    return Padding(
                                      padding: EdgeInsets.only(top: 12.w),
                                      child: AspectRatio(
                                        aspectRatio: 343 / 60,
                                        child: GestureDetector(
                                          onTap: () {
                                            final advertiseUrl = controller.detailBean?.advertiseUrl ?? '';
                                            if (advertiseUrl.isNotEmpty) {
                                              launchUrlString(advertiseUrl, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.r),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: advertiseImage,
                                              fadeOutDuration: Duration.zero,
                                              fadeInDuration: Duration.zero,
                                              cacheKey: advertiseImage,
                                              placeholder: (context, url) => Assets.images.imageLoadingDef.image(
                                                fit: BoxFit.fill,
                                              ),
                                              errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (controller.detailBean?.content?.isNotEmpty == true)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12.w),
                                  child: HtmlWidget(
                                    controller.detailBean!.content!,
                                    textStyle: TextStyle(
                                      color: '#333333'.hexColor,
                                      fontSize: 16.sp,
                                    ),
                                    customStylesBuilder: htmlCustomStyles,
                                    factoryBuilder: () =>
                                        HtmlFactoryBuilder(context, content: controller.detailBean!.content!),
                                    customWidgetBuilder: (dom.Element element) {
                                      if (element.localName == 'table') {
                                        return const SizedBox();
                                      }
                                      // if(element.localName=='p'){
                                      //   return Text(element.text,style: TextStyle(color: '#333333'.hexColor.withOpacity(0.7)),);
                                      // }
                                      return null;
                                    },
                                    onTapUrl: (String url) async {
                                      return launchUrlString(url, mode: LaunchMode.externalApplication);
                                    },
                                  ),
                                ),
                              ),
                            if (controller.detailBean?.tagList?.isNotEmpty == true)
                              SliverToBoxAdapter(
                                child: TagListView(
                                  tagList: controller.detailBean?.tagList ?? [],
                                  onTapItem: (model) => TrackUtils.trackEvent(
                                    userLogType: '109001',
                                    params: model.id,
                                  ),
                                ),
                              )
                            else
                              SliverToBoxAdapter(
                                child: SizedBox(height: 12.w),
                              ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                    commentsData: controller.comments ?? [],
                                    commentBean: controller.comments![index],
                                    relType: 'thread',
                                    sourceType: SourceType.feed,
                                    sourceId: controller.id,
                                    followOnTap: controller.followOnTap,
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
          bottomNavigationBar: controller.detailBean != null
              ? CommonDetailBottomView(
                  viewParams: DetailViewParams(
                      postId: controller.id,
                      relId: controller.id,
                      relType: NetRequest.COMMENT_TYPE_THREAD,
                      favoriteState: controller.detailBean?.favorited!,
                      liked: controller.detailBean?.liked!,
                      shareLink: 'details/thread-${controller.id}',
                      likeCount: controller.detailBean?.likeCount ?? 0,
                      favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                      commentCount: controller.detailBean?.commentCount ?? 0,
                      shareCount: controller.detailBean?.shareCount ?? 0,
                      author: controller.detailBean?.user),
                  sourceType: SourceType.feed,
                )
              : const SizedBox(),
        );
      },
    );
  }
}
