import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/bottom_actions_view.dart';
import 'package:holdem/widget/no_network.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../routes/app_pages.dart';
import '../../utils/date_util.dart';

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
            actions: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.search);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: SvgPicture.asset(
                    Assets.svg.iconSearch,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: controller.noNetwork
              ? NoNetworkView(
                  onRefresh: controller.refreshData,
                )
              : controller.detailBean == null
                  ? const SizedBox()
                  : Container(
                      margin: EdgeInsets.only(top: 12.w),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height,
                      ),
                      decoration: BoxDecoration(
                          color: const Color(0xfff8fbff),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
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
                          ]),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(18.w, 31.5.w, 18.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: AnimatedOpacity(
                                opacity:
                                    controller.detailBean?.cover?.isNotEmpty ==
                                            true
                                        ? 1
                                        : 0,
                                duration: const Duration(milliseconds: 50),
                                child: SizedBox(
                                  width: context.width * 0.6,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          controller.detailBean?.cover ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Assets
                                          .images.imageLoadingDef
                                          .image(fit: BoxFit.fill),
                                      errorWidget: (context, url, error) =>
                                          Assets.images.imageLoadingDef
                                              .image(fit: BoxFit.fill),
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
                              '${DateUtil.formatDateAlias3(controller.detailBean!.createdAt!.millisecondsSinceEpoch, )}发布',
                              style: TextStyle(
                                  color: '#333333'.hexColor, fontSize: 12),
                            ),
                            if (controller
                                    .detailBean?.description?.isNotEmpty ==
                                true)
                              Padding(
                                padding: EdgeInsets.only(top: 6.w),
                                child: Text(
                                  controller.detailBean?.description ?? '',
                                  style: TextStyle(
                                    color: const Color(0xFF333333)
                                        .withOpacity(0.7),
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
                                          text:
                                              '${controller.detailBean?.author ?? ''}',
                                          style: TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            decoration:
                                                TextDecoration.underline,
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
                                  style: TextStyle(
                                      color: Color(0xFF1E1E1E).withOpacity(0.7),
                                      fontSize: 12.sp),
                                ),
                                if (controller
                                        .detailBean?.tagList?.isNotEmpty ==
                                    true)
                                  TagListView(
                                      tagList:
                                          controller.detailBean?.tagList ?? []),
                                SizedBox(height: 16.w),
                                GestureDetector(
                                  onTap: () {
                                    if (controller.detailBean?.book?.downloadUrl
                                            ?.isNotEmpty ==
                                        true) {
                                      launchUrlString(controller
                                          .detailBean!.book!.downloadUrl!);
                                    }
                                  },
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '评论(${controller.detailBean?.commentCount.abbreviateNumber})',
                                  style: TextStyle(
                                    color: const Color(0xff2a2a2a),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                if (controller.comments == null)
                                  const SizedBox()
                                else if (controller.comments?.isNotEmpty ==
                                    true)
                                  ...List.generate(
                                      controller.comments?.length ?? 0,
                                      (index) {
                                    return CommentItem(
                                      commentBean: controller.comments![index],
                                    );
                                  })
                                else
                                  const Center(
                                    child: NoCommentView(),
                                  ),
                              ],
                            ),
                            SizedBox(height: 124.w),
                          ],
                        ),
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
                  shareLink: 'details/book-${controller.id}',
                  likeCount: controller.detailBean?.likeCount ?? 0,
                  favoriteCount: controller.detailBean?.favoriteCount ?? 0,
                  commentCount: controller.detailBean?.commentCount ?? 0,
                  shareCount: controller.detailBean?.shareCount ?? 0,
                ))
              : const SizedBox(),
        );
      },
    );
  }
}
