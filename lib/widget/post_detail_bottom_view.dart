import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/utils/size_fit.dart';

import '../page/forum/page_comment_input.dart';
import '../utils/app_theme.dart';
import '../view/forum/ToastUtils.dart';

/**
 *
 * @ProjectName:  flutter
 * @Desc:
 * @Author:  levin
 * @Date:  2024/5/1
 */
class PostDetailBottomView extends StatefulWidget {
  int postId; //帖子id

  PostDetailBottomView({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailBottomViewState createState() => _PostDetailBottomViewState();
}

class _PostDetailBottomViewState extends State<PostDetailBottomView> {
  bool isCollected = false;
  late int currentPostId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPostId = widget.postId;
  }
  @override
  Widget build(BuildContext context) {
    return bottomInputView();
  }

  Widget bottomInputView() {
    return Container(
        height: 70,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              height: 0.5,
              color: AppTheme.color_F3F3F3,
            ),
            Container(
              height: 69,
              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                      child: GestureDetector(
                        onTap: () {
                          //跳转评论输入页面
                          Get.to(CommentInputPage(postId: currentPostId));
                        },
                        child: Container(
                          height: 40.px,
                          decoration: BoxDecoration(
                            color: AppTheme.color_EFEFEF,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10), // 设置内边距
                          child: Text('我来说两句', style: AppTheme.text999999Size14),
                        ),
                      )

                    // TextField(
                    //   decoration: InputDecoration(
                    //     hintText: '我来说两句',
                    //     filled: true,
                    //     fillColor: AppTheme.color_EFEFEF,
                    //     hintStyle: AppTheme.text999999Size14,
                    //     enabledBorder: OutlineInputBorder(
                    //       borderSide: BorderSide.none,
                    //       borderRadius: BorderRadius.circular(25.0),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide: BorderSide.none,
                    //       borderRadius: BorderRadius.circular(25.0),
                    //     ),
                    //   ),
                    // ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                      onPressed: () {
                        //跳转评论列表页面
                        ToastUtils.showToast('跳转评论列表');
                      },
                      icon: Image.asset(
                        'assets/images/small_comments.png',
                        width: 25.px,
                        height: 25.px,
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isCollected = !isCollected;
                          ToastUtils.showToast(isCollected ? '收藏成功' : '取消收藏');
                        });
                      },
                      icon: Image.asset(
                        isCollected
                            ? 'assets/images/small_collect_selected.png'
                            : 'assets/images/small_collect_unselect.png',
                        width: 25.px,
                        height: 25.px,
                      )),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return sharePopView();
                            });
                      },
                      icon: Image.asset(
                        'assets/images/small_share.png',
                        width: 25.px,
                        height: 25.px,
                      ))
                ],
              ),
            )
          ],
        ));
  }

  Widget sharePopView() {
    return Container(
      height: 180,
      margin: EdgeInsets.fromLTRB(6, 5, 6, 15),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Container(
                  width: 46.px,
                ), // 占位用于调整间距
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '分享',
                    style: AppTheme.text000000Size16,
                  ),
                ),
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/pop_close.png',
                  width: 23.px,
                  height: 23.px,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 14,
              ),
              Expanded(
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            ToastUtils.showToast('分享到Facebook');
                          },
                          icon: Image.asset(
                            'assets/images/share_facebook.png',
                            width: 50.px,
                            height: 50.px,
                          )),
                      Text(
                        'Facebook',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  )),
              Expanded(
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            ToastUtils.showToast('分享到Twitter');
                          },
                          icon: Image.asset(
                            'assets/images/share_twitter.png',
                            width: 50.px,
                            height: 50.px,
                          )),
                      Text(
                        'Twitter',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  )),
              Expanded(
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            ToastUtils.showToast('复制链接');
                          },
                          icon: Image.asset(
                            'assets/images/share_link.png',
                            width: 50.px,
                            height: 50.px,
                          )),
                      Text(
                        '复制链接',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  )),
              SizedBox(
                width: 14,
              )
            ],
          )
        ],
      ),
    );
  }
}
