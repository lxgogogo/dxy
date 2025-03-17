import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/comment_publish/comment_publish_screen.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/page/search_tag/search_tag_screen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../routes/app_pages.dart';
import '../../services/index.dart';
import '../../stores/config_store.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_util.dart';
import '../../widget/circle_image_with_text.dart';
import '../../widget/feed_more_action.dart';
import '../../widget/report_sheet.dart';
import '../mine/login_helper.dart';
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
                      padding: EdgeInsets.fromLTRB(18.w, 8.w, 10.w, 8.w),
                      child: SmartRefresher(
                        enablePullDown: false,
                        enablePullUp: controller.comments?.isNotEmpty == true || !controller.noMore,
                        controller: controller.refreshController,
                        onLoading: controller.onLoading,
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.detailBean?.title ?? '',
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  FeedMoreAction(
                                    actions: {
                                      '屏蔽该内容': () {
                                        controller._onShield(controller.detailBean!.id!);
                                      },
                                      '屏蔽该用户': () {
                                        controller._onShieldUser(controller.detailBean!.user!.id!);
                                      },
                                      '举报该内容': () {
                                        controller._onReport(
                                            controller.detailBean!.id!, controller.detailBean!.user!.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: (controller.detailBean?.sign?.contains('office') ?? false)
                                          ? Text(
                                              '${DateUtil.formatDateAlias3(controller.detailBean!.createdAt!.millisecondsSinceEpoch, hasHM: true)}发布',
                                              style: TextStyle(color: '#333333'.hexColor, fontSize: 12),
                                            )
                                          : CircleImageWithText(
                                              imageUrl:
                                                  (controller.detailBean != null && controller.detailBean!.user != null)
                                                      ? controller.detailBean!.user!.avatar!
                                                      : '',
                                              imageWidth: 20,
                                              imageHeight: 20,
                                              topText: controller.detailBean?.user?.nickname ?? '',
                                              topTextStyle: TextStyle(
                                                  color: '#535861'.hexColor, fontSize: 12, fontWeight: FontWeight.w600),
                                              bottomText1: controller.detailBean?.createdAt != null
                                                  ? '${DateUtil.formatDateAlias3(
                                                      controller.detailBean!.createdAt!.millisecondsSinceEpoch,
                                                    )}发布'
                                                  : '',
                                              bottomText1Style: TextStyle(color: '#333333'.hexColor, fontSize: 12),
                                              bottomText2: '',
                                              bottomText2Style: const TextStyle(),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.detailBean?.content?.isNotEmpty == true)
                              SliverToBoxAdapter(
                                child: HtmlWidget(
                                  controller.detailBean!.content!,
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
                            if (controller.detailBean?.tagList?.isNotEmpty == true)
                              SliverToBoxAdapter(
                                child: TagListView(tagList: controller.detailBean?.tagList ?? []),
                              )
                            else
                              SliverToBoxAdapter(
                                child: SizedBox(height: 16.w),
                              ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '评论${controller.detailBean?.commentCount?.abbreviateNumber ?? '0'}条',
                                    style: TextStyle(
                                      color: '#333333'.hexColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 10.w),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 16.w),
                                    child: Row(
                                      children: [
                                        ClipOval(
                                            child: LoginHelper()
                                                .getUserAvatar(UserStore.of.user?.avatar ?? '', 30.w, 30.w)),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              UserStore.of.checkLogin(() {
                                                Get.bottomSheet(
                                                  isScrollControlled: true,
                                                  enableDrag: false,
                                                  CommentPublishScreen(
                                                    relType: NetRequest.COMMENT_TYPE_THREAD,
                                                    relId: controller.id!,
                                                  ),
                                                );
                                              });
                                            },
                                            child: Container(
                                              height: 30.w,
                                              margin: EdgeInsets.only(left: 12.w),
                                              padding: EdgeInsets.only(left: 12.w),
                                              decoration: BoxDecoration(
                                                color: '#333333'.hexColor.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '说点什么吧...',
                                                style: TextStyle(color: '#333333'.hexColor.withOpacity(0.5)),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
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
                                    relType: 'thread',
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
          bottomNavigationBar: controller.detailBean != null
              ? FeedDetailBottomView(
                  viewParams: PostBottomViewParams(
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
                )
              : const SizedBox(),
        );
      },
    );
  }
}
