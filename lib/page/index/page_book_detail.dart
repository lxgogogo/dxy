import 'dart:convert';

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
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

// import 'dart:html' as html show kIsWeb, AnchorElement;

class BookDetailPage extends StatefulWidget {
  int id;
  BookDetailPage({super.key, required this.id});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
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
      setState(() {
        articleDetailBean = ArticleDetailBean.fromJson(data);
        print('book详情数据：$data');
        loaded = true;
      });
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
          loaded = true;
        });
      }
    });
  }

  // void downloadFile(String url, String fileName) async {
  //   try {
  //     var dio = Dio();
  //     var response = await dio.get(url,
  //         options: Options(responseType: ResponseType.bytes));
  //     final content = response.data;
  //     final link = AnchorElement(
  //         href: 'data:application/octet-stream;charset=utf-16le;base64,' +
  //             base64.encode(content))
  //       ..setAttribute('download', fileName)
  //       ..click();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
      extendBodyBehindAppBar: false, // 将导航条扩展到背景图片后面
      backgroundColor: const Color(0xffE4EEF9),
      appBar: AppBar(
        backgroundColor: const Color(0xffE4EEF9), // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        title: Text('书籍详情'),
      ),
      body: Container(
        // padding: EdgeInsets.only(top: 30.px),
        decoration: BoxDecoration(
            color: const Color(0xffF6FBFF),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.px),
                topRight: Radius.circular(12.px))),

        // decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [
        //       Color(0xFFF4F7FC),
        //       Color(0xFFE4EEF9),
        //       Color(0xFFE4EEF9),
        //     ])
        //     ),
        child: SingleChildScrollView(
          child: bookDetail(),
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
              shareLink: '/book_detail?id=${widget.id}',
              files: [],
            ))
          : Container(),
    ));
  }

  Widget bookDetail() {
    return Column(
      children: [
        SizedBox(
          width: 375.px,
          height: 30.px,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 16.px,
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(5.px), // 设置圆角半径
                child: Image.network(
                  articleDetailBean.cover ?? '',
                  fit: BoxFit.cover,
                  width: 66.px,
                  height: 88.px,
                )),
            SizedBox(
              width: 12.px,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Text(
                  //   articleDetailBean.title ?? '',
                  //   maxLines: 2,
                  //   style: TextStyle(
                  //       color: Color(0xff3B5078),
                  //       fontSize: 19.px,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(
                  //   height: 10.px,
                  // ),
                  Text(
                    '作者：${articleDetailBean.author ?? ''}\n出版社：${articleDetailBean.book?.publisher ?? ''}\n发行时间：${DateFormat('yyyy-MM-dd').format(articleDetailBean.book?.publishDate ?? DateTime.now())}',
                    style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 12.px,
                        height: 1.7),
                  ),
                  // Expanded(child: Container()),
                  // Text('下载资源',style: TextStyle(color: Colors.red),),
                  SizedBox(
                    height: 6.px,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (kIsWeb) {
                        var link = html.document.createElement('a');
                        link.setAttribute("download", 'true');
                        link.setAttribute(
                            "href", articleDetailBean.book!.downloadUrl!);
                        link.click();
                      } else {
                        launchUrl(
                            Uri.parse(articleDetailBean.book!.downloadUrl!));
                      }
                    },
                    child: Container(
                      width: 55.px,
                      height: 20.px,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color(0xff479DFF),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.px))),
                      child: Text(
                        '下载资源',
                        style: TextStyle(color: Colors.white, fontSize: 10.px),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 15.px,
            ),
          ],
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(
              top: 15.px, left: 16.px, right: 16.px, bottom: 15.px),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '详情介绍',
                style:
                    TextStyle(color: const Color(0xff2A2A2A), fontSize: 14.px),
              ),
              SizedBox(
                height: 5.px,
              ),
              Text(
                articleDetailBean.description ?? '',
                maxLines: 100,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xff2A2A2A),
                    fontSize: 12.px,
                    height: 1.4),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 18.px),
          padding: EdgeInsets.only(top: 30.px),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: const Color(0xffE6E6E6)))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '评论(${comments.length})',
                style: TextStyle(
                    color: Color(0xff2a2a2a),
                    fontSize: 12.px,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 18.px,
              ),
              if (loaded && comments.length == 0)
                Center(
                  child: NoDataView(),
                ),
              ...List.generate(comments.length, (index) {
                return CommentItem(
                  commentBean: comments[index],
                );
              }),
              SizedBox(
                height: 100.px,
              ),
              // CommentItem(),
              // CommentItem(),
            ],
          ),
        )
      ],
    );
  }
}
