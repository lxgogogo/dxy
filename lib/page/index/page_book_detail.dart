import 'package:flutter/material.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';

class BookDetailPage extends StatefulWidget {
  int id;
  BookDetailPage({super.key,required this.id});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  ArticleDetailBean articleDetailBean = ArticleDetailBean();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    NetRequest().articleDetail({'id': widget.id}, (data) {
      setState(() {
        articleDetailBean = ArticleDetailBean.fromJson(data);
        print('book详情数据：$data');
      });
    });
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
          Positioned(bottom: 0,left: 0,right: 0,height: 50,
            child: Container(color: Colors.white,),
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
                        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
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
                          articleDetailBean.title??'',
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
                          '作者：迪米勒,斯克兰斯基\n出版社：Two Plus Two Publishing LLC\n发行时间：2006',
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
                              onTap: (){
                                print('点击了下载资源');
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
                      '扑克是一种不断发展的游戏。它的魅力之一就是因为扑克有很多的游戏策略和很多的个人风格，所以没有一种完美的打法能保持不败。的确有些风格对抗一些选手很有效，但有时候却适得其…',
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
                      style: TextStyle(color: Color(0xff3B5078),fontSize: 17.px,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 18.px,),
                    CommentItem(),
                    // CommentItem(),
                  ],
                ),
              ))
            ],
          ))
        ],
      ),
      bottomSheet: PostDetailBottomView(viewParams: PostBottomViewParams(
        postId: widget.id,
        relId: widget.id,
        relType: 'content',
        favoriteState: true,
        title: '',
        content: '',
        files: [],
      )),
    );
  }
}
