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
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

class ArticleDetailPage extends StatefulWidget {
  int id;
  ArticleDetailPage({super.key, required this.id});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  ArticleDetailBean articleDetailBean = ArticleDetailBean();
  List<CommentBean> comments = [];
  bool loaded = false;
  int pageNum = 1;
  var actionEventBus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestDetail();
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.refreshForumPostDetail.eventBusTypeName) {
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
        List<CommentBean> dataList = List<CommentBean>.from(
            data['list'].map((comment) => CommentBean.fromJson(comment)));
        setState(() {
          comments = dataList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
      appBar: AppBar(
        // elevation: 0, // 去除导航条的阴影
        title: Text('详情'),
      ),
      // ignore: unnecessary_null_comparison
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 375.px,
              height: 15.px,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.px),
              child: Column(
                children: [
                  Text(articleDetailBean.title ?? '',
                      style: TextStyle(
                          color: Color(0xff3B5078),
                          fontSize: 22.px,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 15.px,
                  ),
                  if (loaded)
                    Html(data: articleDetailBean.article?.content ?? '',
                    onLinkTap: (url, attributes, element) {
                      if (kIsWeb) {
                                    var link = html.document.createElement('a');
                                    link.setAttribute("href", url as String);
                                    link.click();
                                  } else {
                                    launchUrl(Uri.parse(url as String));
                                  }
                    },),
                  SizedBox(
                    height: 10.px,
                  ),
                  Container(
                    width: 375.px,
                    padding:
                        EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.px),
                            topRight: Radius.circular(15.px))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '评论',
                          style: TextStyle(
                              color: Color(0xff3B5078),
                              fontSize: 17.px,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 18.px,
                        ),

                        if (loaded && comments.length == 0)
                          Center(
                            child: NoDataView(),
                          ),

                        // CommentItem(),
                        // CommentItem(),
                        ...List.generate(comments.length, (index) {
                          return CommentItem(
                            commentBean: comments[index],
                          );
                        }),
                        SizedBox(
                          height: 100.px,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: loaded
          ? PostDetailBottomView(
              viewParams: PostBottomViewParams(
              postId: widget.id,
              relId: widget.id,
              relType: 'content',
              favoriteState: articleDetailBean.favorited ?? false,
              title: '',
              content: '',
              files: [],
            ))
          : Container(),
    ));
  }
}
