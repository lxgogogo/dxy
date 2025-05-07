import 'dart:async';

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
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../services/index.dart';
import '../../utils/date_util.dart';
import '../../utils/track_utils.dart';

part 'book_detail_controller.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookDetailController>(
      init: BookDetailController(),
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
                                  Center(
                                    child: AnimatedOpacity(
                                      opacity: controller.detailBean?.cover?.isNotEmpty == true ? 1 : 0,
                                      duration: const Duration(milliseconds: 50),
                                      child: SizedBox(
                                        width: context.width * 0.6,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: CachedNetworkImage(
                                            imageUrl: controller.detailBean?.cover ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                            errorWidget: (context, url, error) =>
                                                Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.w),
                                  Text(
                                    controller.detailBean?.title ?? '',
                                    style: TextStyle(
                                      color: '#1E1E1E'.hexColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    controller.detailBean!.createdAt != null
                                        ? '${DateUtil.formatDateAlias3(
                                            controller.detailBean!.createdAt!.millisecondsSinceEpoch,
                                            hasHM: true,
                                          )}发布'
                                        : '',
                                    style: TextStyle(color: '#333333'.hexColor, fontSize: 12),
                                  ),
                                  if (controller.detailBean?.description?.isNotEmpty == true)
                                    Padding(
                                      padding: EdgeInsets.only(top: 6.w),
                                      child: Text(
                                        controller.detailBean?.description ?? '',
                                        style: TextStyle(
                                          color: const Color(0xFF333333).withOpacity(0.7),
                                          fontSize: 12.sp,
                                        ),
                                        maxLines: 100,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Opacity(
                                        opacity: 0.70,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '作者： ',
                                                style: TextStyle(
                                                  color: Color(0xFF1E1E1E),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${controller.detailBean?.author ?? ''}',
                                                style: TextStyle(
                                                  color: Color(0xFF1E1E1E),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6.w),
                                      Text(
                                        '出版社：${controller.detailBean?.book?.publisher ?? ''}',
                                        style: TextStyle(
                                            color: Color(0xFF1E1E1E).withOpacity(0.7),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp),
                                      ),
                                      SizedBox(height: 6.w),
                                      Text(
                                        '出版日期：${DateFormat('yyyy-MM-dd').format(controller.detailBean?.book?.publishDate ?? DateTime.now())}',
                                        style: TextStyle(color: Color(0xFF1E1E1E).withOpacity(0.7), fontSize: 12.sp),
                                      ),
                                      if (controller.detailBean?.tagList?.isNotEmpty == true)
                                        TagListView(
                                          tagList: controller.detailBean?.tagList ?? [],
                                          onTapItem: (model) => TrackUtils.trackEvent(
                                            userLogType: '107002',
                                            params: model.id,
                                          ),
                                        ),
                                      SizedBox(height: 16.w),
                                      GestureDetector(
                                        onTap: TrackUtils.trackedTap(
                                          onTap: () async {
                                            // 书籍下载
                                            int bookDownload = controller.detailBean?.userlevel?.bookDownload ?? 0;
                                            bool haveDown = bookDownload != 0 ? true : false;
                                            Log.d('bookDownload:$bookDownload');
                                            if (AppRoutesUtils.haveDownLoadBook(haveDown)) {
                                              if (controller.detailBean?.book?.downloadUrl?.isNotEmpty == true) {
                                                controller.detailBean?.userlevel?.bookDownload =
                                                 (controller.detailBean?.userlevel?.bookDownload ?? 0) - 1;
                                                launchUrlString(controller.detailBean!.book!.downloadUrl!, mode: LaunchMode.externalApplication);
                                                // 书籍下载上报
                                                await CommonService.of.uploadBenefits({
                                                  'type': 'book',
                                                  'value': '1'
                                                });
                                              }
                                            }
                                          },
                                          userLogType: '107001',
                                          params: controller.detailBean?.id,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 160.w,
                                            height: 46.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50.w),
                                              gradient: const LinearGradient(
                                                begin: Alignment(1.00, 0.00),
                                                end: Alignment(-1, 0),
                                                colors: [
                                                  Color(0xFF84BCF9),
                                                  Color(0xFF557BF6),
                                                ],
                                              ),
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
                                    ],
                                  ),
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
                                    sourceType: SourceType.book,
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
          bottomNavigationBar: controller.detailBean != null
              ? CommonDetailBottomView(
                  viewParams: DetailViewParams(
                    postId: controller.id,
                    relId: controller.id,
                    relType: NetRequest.COMMENT_TYPE_CONTENT,
                    favoriteState: controller.detailBean?.favorited ?? false,
                    liked: controller.detailBean?.liked ?? false,
                    shareLink: 'details/book-${controller.id}',
                    likeCount: controller.detailBean?.likeCount ?? 0,
                    favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                    commentCount: controller.detailBean?.commentCount ?? 0,
                    shareCount: controller.detailBean?.shareCount ?? 0,
                  ),
                  sourceType: SourceType.book,
                )
              : const SizedBox(),
        );
      },
    );
  }
}
