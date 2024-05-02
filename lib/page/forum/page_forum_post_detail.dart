import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/forum/page_comment_input.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/label_view.dart';

import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../view/forum/CircleImageWithText.dart';
import '../../view/forum/ToastUtils.dart';
import '../../widget/post_detail_bottom_view.dart';

class PostDetailPage extends StatefulWidget {
  int postId; //帖子id

  PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int currentPostId;
  bool isFollowed = false;

  List<String> items = [
    '评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容'
  ];

  List<String> labelData = [
    '标签1',
    '标签2',
    '标签13',
    '标签14',
  ];

  @override
  void initState() {
    super.initState();
    currentPostId = widget.postId;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
        appBar: AppBar(
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
          backgroundColor: Colors.white,
          title: const Text(''),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/more.png',
                  width: 22.px,
                  height: 22.px,
                ))
          ],
        ),
        body: SafeArea(child: contentView()),
        bottomSheet: PostDetailBottomView(postId: currentPostId,),
        backgroundColor: Colors.white);
  }

  Widget contentView() {
    return ListView(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(16, 5, 16, 17),
            child: Column(
              children: [
                const Text(
                  '大标题大标题大标题大标题大标题大标题大标题大标题大标题大标题',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text3B5078Size22,
                  softWrap: true,
                ),
                SizedBox(
                  height: 15.px,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleImageWithText(
                          imageUrl:
                              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                          imageWidth: 40,
                          imageHeight: 40,
                          topText: '我是一只小小鸟',
                          topTextStyle: const TextStyle(),
                          bottomText1: '发布于2019-2-26 20:30',
                          bottomText1Style: AppTheme.text999999Size11,
                          bottomText2: '',
                          bottomText2Style: const TextStyle()),
                      isFollowed
                          ? followedStatusBtn()
                          : IconButton(
                              onPressed: () {
                                if (isFollowed) {
                                  return;
                                }
                                setState(() {
                                  isFollowed = true;
                                  ToastUtils.showToast( '已关注');
                                });
                              },
                              icon: Image.asset(
                                'assets/images/follow_btn.png',
                                width: 62,
                                height: 28,
                              ))
                    ]),
                SizedBox(height: 16),
                Text(
                    '玩hhpoker俱乐部德扑蕞重要的一点是，在打牌过程中的每个阶段都能知道蕞好的牌是什么。在翻牌前，会相对比较简单。你所能看到的只是自己的两张暗牌，翻牌以后，在转牌、河牌，牌面会变得比较复杂，连老手都经常会搞错。因此，初学hhpoker俱乐部德扑的朋友，首先要练习读牌面。',
                    style: AppTheme.text666666Size16),
                SizedBox(
                  height: 15.px,
                ),
                GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          print('Image Clicked!');
                        },
                        child: Image.network(
                          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                          width: 100,
                          height: 100,
                        ),
                      ); // 替换image_$index.jpg为对应的图片路径
                    }),
                SizedBox(height: 10),
                // Expanded(child: LabelView(isEditLabel: false, labelData: labelData))
                Row(
                  children: [
                    labelView(),
                    SizedBox(
                      width: 10,
                    ),
                    labelView(),
                    SizedBox(
                      width: 10,
                    ),
                    labelView(),
                  ],
                ),
              ],
            )),
        Container(height: 10.px, color: AppTheme.color_F3F3F3),
        Container(
            padding: EdgeInsets.fromLTRB(16, 15, 16, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '评论',
                style: AppTheme.text3B5078Size17,
              ),
              SizedBox(height: 19),
              commentsContent(),
              SizedBox(height: 100)
            ]))
      ],
    );
  }

  Widget commentsContent() {
    List<Widget> commentsList = [];
    for (int i = 0; i < items.length; i++) {
      commentsList.add(CommentItem());
    }
    return Column(
      children: commentsList,
    );
  }

  Widget listDataItem(int i) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
            child: Image.network(
          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        )),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '这是昵称',
              style: AppTheme.text666666Size14,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              items[i].toString(),
              style: AppTheme.text666666Size14,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                          child: const Row(children: [
                        Icon(Icons.message, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          '回复',
                          style: AppTheme.text999999Size12,
                        )
                      ])),
                      GestureDetector(
                        child: const Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              '2222',
                              style: AppTheme.text999999Size12,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ))
      ],
    );
  }

  Widget labelView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_1A008EFF,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
      child: Text(
        '这是标签',
        style: TextStyle(
          color: AppTheme.color_008EFF,
        ),
      ),
    );
  }


  Widget followedStatusBtn() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_0D000000,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
      child: Text('已关注', style: AppTheme.text999999Size13),
    );
    ;
  }
}
