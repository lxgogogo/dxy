import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:holdem/widget/special_classic_footer.dart';
import 'package:html/dom.dart' as dom;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/date_util.dart';
import '../../utils/track_utils.dart';

part 'article_detail_controller.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArticleDetailController>(
      init: ArticleDetailController(),
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
                      padding: EdgeInsets.fromLTRB(18.w, 8.w, 10.w, 86.w),
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
                                      color: '#333333'.hexColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.w),
                                  Text(
                                    controller.detailBean!.createdAt != null
                                        ? '${DateUtil.formatDateAlias3(
                                            controller.detailBean!.createdAt!.millisecondsSinceEpoch,
                                            hasHM: true,
                                          )}发布'
                                        : '',
                                    style: TextStyle(color: '#333333'.hexColor, fontSize: 12),
                                  ),
                                  SizedBox(height: 5.w),
                                  if (controller.detailBean?.article?.content?.isNotEmpty == true)
                                    HtmlWidget(
                                      controller.detailBean!.article!.content!,
                                      customStylesBuilder: htmlCustomStyles,
                                      factoryBuilder: () => HtmlFactoryBuilder(
                                        context,
                                        content: controller.detailBean!.article!.content!,
                                      ),
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
                                  if (controller.detailBean?.tagList?.isNotEmpty == true)
                                    TagListView(
                                      tagList: controller.detailBean?.tagList ?? [],
                                      onTapItem: (model) => TrackUtils.trackEvent(
                                        userLogType: '105001',
                                        params: model.id,
                                      ),
                                    )
                                  else
                                    SizedBox(height: 16.w),
                                  Text(
                                    '评论${controller.detailBean?.commentCount?.abbreviateNumber ?? '0'}条',
                                    style: TextStyle(
                                      color: '#333333'.hexColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
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
              ? CommonDetailBottomView(
                  viewParams: DetailViewParams(
                    postId: controller.id,
                    relId: controller.id,
                    relType: NetRequest.COMMENT_TYPE_CONTENT,
                    favoriteState: controller.detailBean?.favorited ?? false,
                    liked: controller.detailBean?.liked ?? false,
                    shareLink: 'details/article-${controller.id}',
                    likeCount: controller.detailBean?.likeCount ?? 0,
                    favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                    commentCount: controller.detailBean?.commentCount ?? 0,
                    shareCount: controller.detailBean?.shareCount ?? 0,
                  ),
                  contentType: ContentType.article,
                )
              : const SizedBox(),
        );
      },
    );
  }
}
