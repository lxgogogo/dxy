import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

class ArticleDetailPage extends StatefulWidget {
  final int id;

  const ArticleDetailPage({super.key, required this.id});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
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
      if (mounted) {
        setState(() {
          articleDetailBean = ArticleDetailBean.fromJson(data);
          loaded = true;
        });
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
            Column(
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
                        if (kIsWeb) {
                          var link = html.document.createElement('a');
                          link.setAttribute("href", url as String);
                          link.click();
                        } else {
                          launchUrl(Uri.parse(url as String));
                        }
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
                )
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
                shareLink: '/article_detail?id=${widget.id}',
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
