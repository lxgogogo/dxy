import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        // title: Text('hhh'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_top.png', // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              color: Colors.white,
            ),
          ),
          SafeArea(
              child: Column(
            children: [
              SizedBox(
                width: 375.px,
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
                        width: 120.px,
                        height: 165.px,
                      )),
                  SizedBox(
                    width: 12.px,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          articleDetailBean.title ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              color: Color(0xff3B5078),
                              fontSize: 19.px,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.px,
                        ),
                        Text(
                          '作者：${articleDetailBean.author ?? ''}\n出版社：${articleDetailBean.book?.publisher ?? ''}\n发行时间：${DateFormat('yyyy-MM-dd').format(articleDetailBean.book?.publishDate ?? DateTime.now())}',
                          style: TextStyle(
                              color: Color(0xff3B5078),
                              fontSize: 12.px,
                              height: 1.8),
                        ),
                        // Expanded(child: Container()),
                        // Text('下载资源',style: TextStyle(color: Colors.red),),
                        SizedBox(
                          height: 8.px,
                        ),
                        Row(
                          children: [
                            HoldemHighlightBtn(
                                onTap: () {
                                  print('点击了下载资源');
                                  String fileName = getFileNameFromUrl(
                                      articleDetailBean.book!.downloadUrl!);
                                  downloadRemoteFile(
                                      articleDetailBean.book!.downloadUrl!,
                                      fileName);
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/download.png',
                                      width: 20.px,
                                      height: 20.px,
                                    ),
                                    const Text(
                                      '下载资源',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          ],
                        )
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
                      style: TextStyle(
                          color: Color(0xff3B5078),
                          fontSize: 16.px,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5.px,
                    ),
                    Text(
                      articleDetailBean.description ?? '',
                      maxLines: 10,
                      style: TextStyle(
                          color: Color(0xff666666),
                          fontSize: 14.px,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                width: 375.px,
                padding: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
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
                  ],
                ),
              ))
            ],
          ))
        ],
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
    );
  }
}
