import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/comment/page_comments.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:universal_html/html.dart' as html;

import '../model/upload_file.dart';
import '../page/forum/page_comment_input.dart';
import '../page/mine/page_login.dart';
import '../utils/app_theme.dart';
import '../utils/global.dart';
import '../view/forum/ToastUtils.dart';

/**
 *
 * @ProjectName:  flutter
 * @Desc:
 * @Author:  levin
 * @Date:  2024/5/1
 */
class PostDetailBottomView extends StatefulWidget {
  PostBottomViewParams viewParams;

  PostDetailBottomView({Key? key, required this.viewParams}) : super(key: key);

  @override
  _PostDetailBottomViewState createState() => _PostDetailBottomViewState();
}

class _PostDetailBottomViewState extends State<PostDetailBottomView> {
  bool _isFavorite = false;
  late PostBottomViewParams viewParams;
  bool _isMounted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    viewParams = widget.viewParams;
    _isFavorite =
        viewParams.favoriteState != null ? viewParams.favoriteState! : false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
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
                      if (!Global().hasLogin) {
                        Get.to(LoginPage());
                        return;
                      }
                      //跳转评论输入页面
                      Get.to(CommentInputPage(
                          relType: viewParams.relType!,
                          relId: viewParams.relId!));
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
                  )),
                  SizedBox(width: 10),
                  viewParams.relType!.isNotEmpty && viewParams.relType! == 'thread' ?
                  IconButton(
                      onPressed: () {
                        if (!Global().hasLogin) {
                          Get.to(LoginPage());
                          return;
                        }
                        //点赞
                        NetRequest().contentLike({
                          'relType': viewParams.relType!,
                          'relId': viewParams.relId!,
                          'state': viewParams.liked?? false ? false : true
                        }, (data) {
                          setState(() {
                            viewParams.liked = !viewParams.liked!;
                          });
                        });
                      },
                      icon: Image.asset(
                        viewParams.liked ?? false
                            ? 'assets/images/small_like_selected.png'
                            : 'assets/images/small_like_unselect.png',
                        width: 25.px,
                        height: 25.px,
                      )) : Container(),
                  IconButton(
                      onPressed: () {
                        if (!Global().hasLogin) {
                          Get.to(LoginPage());
                          return;
                        }
                        //跳转评论列表页面
                        // ToastUtils.showToast('跳转评论列表');
                        Get.to(CommentListPage(id: viewParams.relId!,relType: viewParams.relType!,));
                      },
                      icon: Image.asset(
                        'assets/images/small_comments.png',
                        width: 25.px,
                        height: 25.px,
                      )),
                  IconButton(
                      onPressed: () {
                        if (!Global().hasLogin) {
                          Get.to(LoginPage());
                          return;
                        }
                        _favoriteToggle();
                      },
                      icon: Image.asset(
                        _isFavorite
                            ? 'assets/images/small_collect_selected.png'
                            : 'assets/images/small_collect_unselect.png',
                        width: 25.px,
                        height: 25.px,
                      )),
                  IconButton(
                      onPressed: () {
                        var shareData = {
                          "title": '德学院',
                          "text": '欢迎来到德学院',
                          "url": 'https://reptile-vue.dexin62.com/',
                        };
                        html.window.navigator.share(shareData);
                        // html.window.navigator.share(shareData);
                        // Share.shareXFiles([XFile('https://bbs.api.robot-9.com/static/avatar.png')], text: 'Great picture');
                        //   showModalBottomSheet(
                        //       backgroundColor: AppTheme.white,
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return sharePopView();
                        //       });
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
      height: 190.px,
      width: MediaQuery.of(context).size.width,
      // color: AppTheme.white,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), // 顶部左侧设置圆角
          topRight: Radius.circular(20.0), // 顶部右侧设置圆角
        ),
        color: AppTheme.white,
      ),
      padding: EdgeInsets.fromLTRB(6, 5, 6, 15),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Container(
                  width: 35.px,
                ), // 占位用于调整间距
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '分享',
                    style: AppTheme.text000000Size16W500,
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
            height: 30,
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

  void _favoriteToggle() {
    NetRequest().favoriteToggle(
        viewParams.relType!, viewParams.relId!, !_isFavorite, (data) {
      if (_isMounted) {
        ToastUtils.showToast(_isFavorite ? '取消成功' : '收藏成功');
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    });
  }
}

class PostBottomViewParams {
  int? postId; //帖子id
  int? relId; // 评论对象id
  String? relType; //  评论对象类型   // thread 帖子，content 内容，comment 评论
  bool? favoriteState; //收藏状态 true  false
  bool? liked; //点赞状态 true  false
  String? title; //帖子标题
  String? content; //帖子内容
  List<UploadFile>? files; // 帖子的图片或者视频集合

  PostBottomViewParams({
    this.postId,
    @required this.relId,
    @required this.relType,
    @required this.favoriteState,
    @required this.title,
    @required this.content,
    @required this.files,
    this.liked = false
  });
}
