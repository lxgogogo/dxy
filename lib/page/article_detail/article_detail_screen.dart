import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

part 'article_detail_controller.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int id;

  const ArticleDetailScreen({super.key, required this.id});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
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
      if (mounted) {
        if (data == null) {
          showToast('该文章已删除');
          Get.back();
          return;
        }
        articleDetailBean = ArticleDetailBean.fromJson(data);
        loaded = true;
        setState(() {});
      }
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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          '详情',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.px, 8.px, 18.px, 124.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              articleDetailBean.title ?? '',
              style: TextStyle(
                color: const Color(0xff2c2c2c),
                fontSize: 20.px,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (loaded)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.px),
                child: Html(
                  data: articleDetailBean.article?.content ?? '',
                  onLinkTap: (url, attributes, element) {
                    launchUrl(Uri.parse(url as String));
                  },
                ),
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
          ],
        ),
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
                shareLink: 'details/article-${widget.id}',
                likeCount: articleDetailBean.likeCount ?? 0,
                favoriteCount: articleDetailBean.favoriteCount ?? 0,
                commentCount: articleDetailBean.commentCount ?? 0,
                shareCount: articleDetailBean.shareCount ?? 0,
              ),
            )
          : Container(),
    ));
  }
}
