import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

class BookDetailPage extends StatefulWidget {
  final int id;

  const BookDetailPage({super.key, required this.id});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  ArticleDetailBean articleDetailBean = ArticleDetailBean();
  List<CommentBean> comments = [];
  bool loaded = false;
  int pageNum = 1;

  @override
  void initState() {
    super.initState();
    requestDetail();
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshForumPostDetail.eventBusTypeName) {
        requestDetail();
      }
    });
  }

  requestDetail() {
    NetRequest().articleDetail({'id': widget.id}, (data) {
      setState(() {
        articleDetailBean = ArticleDetailBean.fromJson(data);
        loaded = true;
      });
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

  void downloadRemoteFile(String url, String fileName) {
    // if (kIsWeb) {
    //   html.AnchorElement anchor = html.AnchorElement(
    //     href: url,
    //   );
    //   anchor.setAttribute('download', fileName);
    //   anchor.click();
    //   anchor.remove();
    // }
  }

  String getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    List<String> pathSegments = uri.pathSegments;
    return pathSegments.last;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '书籍详情',
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: 16.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Image.asset(
              'assets/images/back.png',
              width: 22.px,
              height: 22.px,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(top: 12.px),
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
                  offset: Offset(0, 1.px),
                  blurRadius: 2.rpx,
                  spreadRadius: -1.px,
                ),
                BoxShadow(
                  color: const Color(0xffffffff),
                  offset: Offset(0, -1.px),
                  blurRadius: 2.rpx,
                  spreadRadius: 0,
                ),
              ]),
          child: bookDetail(),
        ),
        bottomSheet: loaded
            ? PostDetailBottomView(
                viewParams: PostBottomViewParams(
                postId: widget.id,
                relId: widget.id,
                relType: NetRequest.COMMENT_TYPE_CONTENT,
                favoriteState: articleDetailBean.favorited ?? false,
                title: '',
                liked: articleDetailBean.liked ?? false,
                content: '',
                files: [],
                shareLink: '/book_detail?id=${widget.id}',
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
      padding: EdgeInsets.fromLTRB(18.px, 31.5.px, 18.px, 0),
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
                  width: 66.px,
                  height: 88.px,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: articleDetailBean.cover ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                      errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.px),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '作者：${articleDetailBean.author ?? ''}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px),
                    ),
                    SizedBox(height: 6.px),
                    Text(
                      '出版社：${articleDetailBean.book?.publisher ?? ''}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px),
                    ),
                    SizedBox(height: 6.px),
                    Text(
                      '出版日期：${DateFormat('yyyy-MM-dd').format(articleDetailBean.book?.publishDate ?? DateTime.now())}',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px),
                    ),
                    SizedBox(height: 6.px),
                    GestureDetector(
                      onTap: () {
                        if (articleDetailBean.book?.downloadUrl?.isNotEmpty == true) {
                          launchUrl(Uri.parse(articleDetailBean.book!.downloadUrl!));
                        }
                      },
                      child: Container(
                        width: 55.px,
                        height: 19.px,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff479DFF),
                          borderRadius: BorderRadius.all(Radius.circular(10.px)),
                        ),
                        child: Text(
                          '下载资源',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.px,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30.px),
          Text(
            '详情介绍',
            style: TextStyle(
              color: const Color(0xff2A2A2A),
              fontSize: 14.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.px),
          Text(
            articleDetailBean.description ?? '',
            style: TextStyle(
              color: const Color(0xff2A2A2A),
              fontSize: 12.px,
            ),
            maxLines: 100,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 1.px,
            margin: EdgeInsets.only(top: 14.px, bottom: 36.5.px),
            color: const Color(0xffe6e6e6),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '评论(${articleDetailBean.commentCount})',
                style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10.px),
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
          SizedBox(height: 124.px),
        ],
      ),
    );
  }
}
