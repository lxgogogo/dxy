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
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_util.dart';
import '../../widget/circle_image_with_text.dart';
import '../mine/login_helper.dart';

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
          ),
          backgroundColor: Colors.white,
          extendBody: true,
          body: controller.noNetwork
              ? NoNetworkView(
                  onRefresh: controller.refreshData,
                )
              : controller.detailBean == null
                  ? const SizedBox()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18.w, 8.w, 18.w, 124.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            controller.detailBean?.title ?? '',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CircleImageWithText(
                                    imageUrl: (controller.detailBean != null &&
                                            controller.detailBean!.user != null)
                                        ? controller.detailBean!.user!.avatar!
                                        : '',
                                    imageWidth: 20,
                                    imageHeight: 20,
                                    topText:
                                        controller.detailBean?.user?.nickname ??
                                            '',
                                    topTextStyle: TextStyle(
                                        color: '#535861'.hexColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                    bottomText1: controller
                                                .detailBean?.createdAt !=
                                            null
                                        ? '${DateUtil.formatDateAlias(controller.detailBean!.createdAt!.millisecondsSinceEpoch, hasBefore: true)}发布'
                                        : '',
                                    bottomText1Style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12),
                                    bottomText2: '',
                                    bottomText2Style: const TextStyle(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.detailBean?.content?.isNotEmpty ==
                              true)
                            HtmlWidget(
                              controller.detailBean!.content!,
                              customStylesBuilder: htmlCustomStyles,
                              factoryBuilder: () => HtmlFactoryBuilder(context,
                                  content: controller.detailBean!.content!),
                              customWidgetBuilder: (dom.Element element) {
                                if (element.localName == 'table') {
                                  return const SizedBox();
                                }
                                // if(element.localName=='p'){
                                //   return Text(element.text,style: TextStyle(color: '#333333'.hexColor),);
                                // }
                                return null;
                              },
                              onTapUrl: (String url) async {
                                return launchUrlString(url,
                                    mode: LaunchMode.externalApplication);
                              },
                            ),
                          // _buildMediaView(),
                          if (controller.detailBean?.tagList?.isNotEmpty ==
                              true)
                            TagListView(
                                tagList: controller.detailBean?.tagList ?? [])
                          else
                            SizedBox(height: 16.w),
                          Column(
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
                              GestureDetector(
                                onTap: (){
                                    UserStore.of.checkLogin(() {
                                      Get.bottomSheet(
                                        isScrollControlled: true,
                                        CommentPublishScreen(
                                          relType:  NetRequest.COMMENT_TYPE_THREAD,
                                          relId: controller.id!,
                                        ),
                                      );
                                    });

                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16.w),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                          child: LoginHelper().getUserAvatar(
                                              UserStore.of.user.avatar ?? '',
                                              30.w,
                                              30.w)),
                                      Expanded(
                                        child: Container(
                                          height: 30.w,
                                          margin: EdgeInsets.only(left: 12.w),
                                          padding: EdgeInsets.only(left: 12.w),
                                          decoration: BoxDecoration(
                                            color: '#333333'
                                                .hexColor
                                                .withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '说点什么吧',
                                            style: TextStyle(
                                                color: '#333333'
                                                    .hexColor
                                                    .withOpacity(0.5)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (controller.comments == null)
                                const SizedBox()
                              else if (controller.comments?.isNotEmpty == true)
                                ...List.generate(controller.comments!.length,
                                    (index) {
                                  return CommentItem(
                                    commentBean: controller.comments![index],
                                    relType: 'thread',
                                  );
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
                    author: controller.detailBean?.user
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
