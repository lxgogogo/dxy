import 'package:flutter/material.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/holdem_btn.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
        appBar: AppBar(
          // elevation: 0, // 去除导航条的阴影
          title: Text('视频详情'),
        ),
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
                    Text('AK在不同位置不同入局：翻牌三张发出来后怎么打？',
                        style: TextStyle(
                            color: Color(0xff3B5078),
                            fontSize: 22.px,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 15.px,
                    ),
                    Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                            width: 40.px,
                            height: 40.px,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 12.px,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'data',
                              style: TextStyle(
                                  color: Color(0xff3B5078), fontSize: 13.px),
                            ),
                            Text(
                              '发布于2019-2-26 20:30',
                              style: TextStyle(
                                  color: Color(0xff999999), fontSize: 11.px),
                            )
                          ],
                        ),
                        Spacer(),
                        HoldemHighlightBtn(
                            onTap: () {
                              print('点击了下载资源1');
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/add.png',
                                  width: 12.px,
                                  height: 12.px,
                                ),
                                SizedBox(
                                  width: 2.px,
                                ),
                                const Text(
                                  '关注',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10.px,
              ),
              GestureDetector(
                child: Container(
                  width: 375.px,
                  height: 210.px,
                  child: Stack(
                    children: [
                      Image.network(
                        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                        width: 375.px,
                        height: 210.px,
                        fit: BoxFit.cover,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/play.png',
                          width: 50.px,
                          height: 50.px,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
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
                    CommentItem(),
                    // CommentItem(),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
