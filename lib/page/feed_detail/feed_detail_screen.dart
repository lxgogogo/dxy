import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../utils/app_theme.dart';
import '../../utils/media_helper.dart';
import '../../widget/circle_image_with_text.dart';

part 'feed_detail_controller.dart';

class FeedDetailScreen extends GetView<FeedDetailController> {
  const FeedDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedDetailController>(
      init: FeedDetailController(),
      builder: (logic) {
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
                    controller.detailBean?.title ?? '',
                    style: TextStyle(
                      color: const Color(0xff2c2c2c),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CircleImageWithText(
                            imageUrl: (controller.detailBean != null && controller.detailBean!.user != null)
                                ? controller.detailBean!.user!.avatar!
                                : '',
                            imageWidth: 40,
                            imageHeight: 40,
                            topText: controller.detailBean?.user?.nickname ?? '',
                            topTextStyle: const TextStyle(),
                            bottomText1: controller.detailBean?.createdAt != null
                                ? '发布于${DateFormat('MM-dd HH:mm').format(controller.detailBean!.createdAt!)}'
                                : '',
                            bottomText1Style: AppTheme.text999999Size11,
                            bottomText2: '',
                            bottomText2Style: const TextStyle(),
                          ),
                        ),
                        if ((controller.detailBean?.user?.id ?? 0) != 0)
                          Visibility(
                            visible: isOwnerPost() ? false : true,
                            child: GestureDetector(
                              onTap: controller._followToggle,
                              child: controller.detailBean?.user?.followed == true
                                  ? Container(
                                      height: 28.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffd8d8d8),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      child: Text(
                                        '已关注',
                                        style: TextStyle(
                                          color: const Color(0xff95a3c4),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 28.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff249cfc),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      child: Text(
                                        '+关注',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (controller.detailBean?.content?.isNotEmpty == true)
                    HtmlWidget(
                      controller.detailBean!.content!,
                      customStylesBuilder: htmlCustomStyles,
                      factoryBuilder: () => HtmlFactoryBuilder(context, content: controller.detailBean!.content!),
                      customWidgetBuilder: (dom.Element element) {
                        if (element.localName == 'table') {
                          return const SizedBox();
                        }
                        return null;
                      },
                      onTapUrl: (String url) async {
                        return launchUrlString(url, mode: LaunchMode.externalApplication);
                      },
                    ),
                  // _buildMediaView(),
                  SizedBox(height: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '评论(${controller.detailBean?.commentCount ?? 0})',
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
                          return CommentItem(
                            commentBean: controller.comments![index],
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
                    ),
                    tagList: controller.detailBean?.tagList ?? [],
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }

  ///是自己的帖子 不显示关注
  bool isOwnerPost() {
    if (controller.detailBean != null) {
      var ownerId = UserStore.of.user.id;
      if (controller.detailBean!.user?.id == ownerId) {
        return true;
      }
    }
    return false;
  }

  ///显示媒体文件 图片或者视频
  Widget _buildMediaView() {
    if (controller.detailBean?.files?.isNotEmpty != true) {
      return const SizedBox();
    }
    if (controller.hasVideo) {
      return GestureDetector(
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
                blurRadius: 2.rpx,
                spreadRadius: -1.w,
              ),
              BoxShadow(
                color: const Color(0xffffffff),
                offset: Offset(0, -1.w),
                blurRadius: 2.rpx,
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
                      imageUrl: controller.detailBean?.cover ?? '',
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
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.w),
      itemCount: controller.detailBean?.files?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            MediaHelper().imagePerView(
              context,
              controller.detailBean!.files!.map((e) => e.url ?? '').toList(),
              index,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: controller.detailBean?.files?[index].url ?? '',
              placeholder: (context, url) => Image.asset(
                'assets/images/image_loading_def.png',
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/image_loading_def.png',
              ),
            ),
          ),
        );
      },
    );
  }
}
