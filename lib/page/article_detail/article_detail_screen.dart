import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:html/dom.dart' as dom;

part 'article_detail_controller.dart';

class ArticleDetailScreen extends GetView<ArticleDetailController> {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArticleDetailController>(
      init: ArticleDetailController(),
      builder: (logic) {
        return BackgroundContainer(
          child: Scaffold(
            appBar: CommonAppBar.arrowBack(
              context,
              title: '详情',
            ),
            backgroundColor: Colors.transparent,
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
                  SizedBox(height: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '评论(${controller.detailBean?.commentCount ?? 0})',
                        style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.w, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10.w),
                      if (controller.comments == null)
                        const SizedBox()
                      else if (controller.comments?.isNotEmpty == true)
                        ...List.generate(controller.comments?.length ?? 0, (index) {
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
                      relType: NetRequest.COMMENT_TYPE_CONTENT,
                      favoriteState: controller.detailBean?.favorited ?? false,
                      liked: controller.detailBean?.liked ?? false,
                      shareLink: 'details/article-${controller.id}',
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
}
