import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../page/forum/page_forum_post_detail.dart';
import '../../utils/app_theme.dart';

class PostListItemView extends StatefulWidget {
  int itemIndex;

  PostListItemView({Key? key, required this.itemIndex}) : super(key: key);

  @override
  _PostDetailBottomViewState createState() => _PostDetailBottomViewState();
}

class _PostDetailBottomViewState extends State<PostListItemView> {
  bool isCollected = false;
  late int itemIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemIndex = widget.itemIndex;
  }

  @override
  Widget build(BuildContext context) {
    return listDataItem(itemIndex);
  }

  Widget listDataItem(int index) {
    return GestureDetector(
        onTap: () {
          Get.to(PostDetailPage(postId: 111111));
        },
        child: Container(
            padding: EdgeInsets.all(12.px),
            margin: EdgeInsets.only(top: 10.px, left: 10.px, right: 10.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEEF7FE),
                  Color(0xFFEEF7FF),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 4.0,
                  spreadRadius: -4.0,
                  offset: Offset(0.0, 6.0),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(13.px)),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这是一个标题这是一个标题这是一个标题这是一个标题这是一个标题这是一个标题这是一个标题',
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text3B5078Size17,
                  ),
                  SizedBox(
                    height: 8.px,
                  ),
                  Row(
                    children: [
                      Container(
                        child: ClipOval(
                          child: Image.network(
                            'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5.px,
                      ),
                      Text(
                        '这个昵称',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.px,
                  ),
                  const Text(
                    '很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本很长的文本',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text666666Size14,
                    softWrap: true,
                  ),
                  Visibility(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.px,
                          ),
                          mediaContent(index)
                        ],
                      ),
                      visible: index == 2 ? false : true),
                  SizedBox(
                    height: 5.px,
                  ),
                  Text(
                    '121 赞同 · 78 评论 · 90 收藏',
                    style: AppTheme.text999999Size12,
                    maxLines: 1,
                  )
                ])));
  }

  Widget mediaContent(int index) {
    if (index == 0) {
      return singleImageView(
          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp');
    } else if (index == 1) {
      //视频
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
        child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 335,
                  height: 188,
                  child: Image.network(
                    'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                    width: 335,
                    height: 188,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: AssetImage('assets/images/play_btn.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )),
      );
    } else if (index == 2) {
      //不显示
      return Image.network(
        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
        width: 335,
        height: 188,
      );
    } else if (index == 3) {
      //2张
      int num = 2;
      double screenWidth = MediaQuery.of(context).size.width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 10 -15) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
        ],
      );
    } else if (index == 4) {
      //大于等于3张
      int num = 3;
      double screenWidth = MediaQuery
          .of(context)
          .size
          .width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 25) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp'),
        ],
      );
    } else {
      return singleImageView(
          'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp');
    }
  }

  Widget singleImageView(String imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl,
          width: 130,
          height: 90,
          fit: BoxFit.fill,
        ));
  }

  Widget multipleImageView(double imageWidth, String imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl,
          width: imageWidth,
          height: 111,
          fit: BoxFit.cover,
        ));
  }
}