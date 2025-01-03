import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
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
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'book_detail_controller.dart';

class BookDetailScreen extends StatefulWidget {
  final int id;

  const BookDetailScreen({super.key, required this.id});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  ArticleDetailBean articleDetailBean = ArticleDetailBean();
  List<CommentBean> comments = [];
  bool loaded = false;
  int pageNum = 1;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    requestDetail();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail();
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  requestDetail() {
    NetRequest().contentShow({'id': widget.id}, (data) {
      if (data == null) {
        ToastUtils.showToast('该书籍已删除');
        Get.back();
        return;
      }
      articleDetailBean = ArticleDetailBean.fromJson(data);
      loaded = true;
      setState(() {});
    });

    NetRequest().commentList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'relType': 'content', 'relId': widget.id}
    }, (data) {
      if (mounted) {
        List<CommentBean> dataList =
            List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
        setState(() {
          comments = dataList;
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '书籍详情'),
        backgroundColor: Colors.transparent,
        body: Container(
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
          child: bookDetail(),
        ),
        bottomNavigationBar: loaded
            ? FeedDetailBottomView(
                viewParams: PostBottomViewParams(
                postId: widget.id,
                relId: widget.id,
                relType: NetRequest.COMMENT_TYPE_CONTENT,
                favoriteState: articleDetailBean.favorited ?? false,
                liked: articleDetailBean.liked ?? false,
                shareLink: 'details/book-${widget.id}',
                likeCount: articleDetailBean.likeCount ?? 0,
                favoriteCount: articleDetailBean.favoriteCount ?? 0,
                commentCount: articleDetailBean.commentCount ?? 0,
                shareCount: articleDetailBean.shareCount ?? 0,
              ))
            : Container(),
      ),
    );
  }

  Widget bookDetail() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 31.5.w, 18.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: articleDetailBean.cover?.isNotEmpty == true ? 1 : 0,
                duration: const Duration(milliseconds: 50),
                child: SizedBox(
                  width: 66.w,
                  height: 88.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: articleDetailBean.cover ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/image_loading_def.png',
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/image_loading_def.png',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '作者：${articleDetailBean.author ?? ''}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.w),
                    Text(
                      '出版社：${articleDetailBean.book?.publisher ?? ''}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.w),
                    Text(
                      '出版日期：${DateFormat('yyyy-MM-dd').format(articleDetailBean.book?.publishDate ?? DateTime.now())}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.w),
                    GestureDetector(
                      onTap: () {
                        if (articleDetailBean.book?.downloadUrl?.isNotEmpty == true) {
                          launchUrlString(articleDetailBean.book!.downloadUrl!);
                        }
                      },
                      child: Container(
                        width: 55.w,
                        height: 19.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff479DFF),
                          borderRadius: BorderRadius.all(Radius.circular(10.w)),
                        ),
                        child: Text(
                          '下载资源',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (articleDetailBean.tagList?.isNotEmpty == true)
            TagListView(tagList: articleDetailBean.tagList ?? [])
          else
            SizedBox(height: 30.w),
          Text(
            '详情介绍',
            style: TextStyle(
              color: const Color(0xff2A2A2A),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (articleDetailBean.description?.isNotEmpty == true)
            Padding(
              padding: EdgeInsets.only(top: 8.w),
              child: Text(
                articleDetailBean.description ?? '',
                style: TextStyle(
                  color: const Color(0xff2A2A2A),
                  fontSize: 12.sp,
                ),
                maxLines: 100,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Container(
            height: 1.w,
            margin: EdgeInsets.only(top: 12.w, bottom: 32.w),
            color: const Color(0xffe6e6e6),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '评论(${articleDetailBean.commentCount.abbreviateNumber})',
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.w),
              if (loaded)
                if (comments.isNotEmpty)
                  ...List.generate(comments.length, (index) {
                    return CommentItem(
                      commentBean: comments[index],
                    );
                  })
                else
                  const Center(
                    child: NoDataView(),
                  ),
            ],
          ),
          SizedBox(height: 124.w),
        ],
      ),
    );
  }
}
