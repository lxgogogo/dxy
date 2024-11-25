import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:holdem/page/comment/page_comments.dart';
import 'package:holdem/page/comment/page_publish_comment.dart';
import 'package:holdem/utils/env.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

import '../model/upload_file.dart';
import '../page/forum/page_comment_input.dart';
import '../page/login/login_screen.dart';
import '../utils/app_theme.dart';
import '../utils/eventbus/EventBusAction.dart';
import '../utils/eventbus/EventBusManager.dart';
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
  final _textEditingController = TextEditingController();
  late PostBottomViewParams viewParams;
  bool _isMounted = false;
  bool _canSend = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    viewParams = widget.viewParams;
  }

  @override
  void didUpdateWidget(covariant PostDetailBottomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    viewParams = widget.viewParams;
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

  void _submitComment(String commentContent, BuildContext context) {
    NetRequest().commentCreate(viewParams.relType!, viewParams.relId!, commentContent, (data) {
      EventBusUtil.of.fire(EventRefreshPage(viewParams.relType!));
      ToastUtils.showToast('发布成功');
      _textEditingController.clear();
      Navigator.pop(context);
    });
  }

  popDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许底部弹窗超出屏幕高度
      builder: (BuildContext context) {
        // 定义 TextEditingController 以跟踪输入内容
        // final _textEditingController = TextEditingController();
        String aaa = '';

        return StatefulBuilder(builder: (c, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // 适配软键盘高度
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: const Color(0xffF2F8FD),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.px), topRight: Radius.circular(10.px))),

              // border: Border.all()),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.px,
                      padding: EdgeInsets.only(left: 15.px, right: 15.px, top: 5.px, bottom: 5.px),
                      decoration: BoxDecoration(
                          color: Color(0xff95A3C4).withOpacity(0.1), borderRadius: BorderRadius.circular(4.px)),
                      child: TextField(
                        // maxLength: 100,
                        maxLines: 100,
                        controller: _textEditingController,
                        autofocus: true,
                        // 自动获取焦点
                        decoration: InputDecoration(
                          hintText: '说点什么...',
                          hintStyle: AppTheme.text999999Size16,
                          border: InputBorder.none,
                          // border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // 监听输入框内容变化,更新按钮状态

                          setState(() {
                            aaa = value;
                            _canSend = value.isNotEmpty;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      String commentContent = _textEditingController.text;
                      if (commentContent.isNotEmpty && commentContent.length >= 5) {
                        _submitComment(commentContent, context);

                        // Navigator.of(context).pop();
                      } else {
                        ToastUtils.showToast('评论内容不能低于5个字符');
                      }
                    },
                    child: Container(
                      width: 50.px,
                      height: 24.px,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.px),
                          color: _canSend ? Color(0xFF249CFC) : Color(0x80249CFC)),
                      child: Text(
                        '发布',
                        style: TextStyle(color: Colors.white, fontSize: 12.px),
                      ),
                    ),
                  )
                  // ElevatedButton(
                  //   onPressed: _canSend
                  //       ? () {
                  //           // 处理发送逻辑
                  //           print('发送内容: ${_textEditingController.text}');
                  //           Navigator.of(context).pop(); // 关闭底部弹窗
                  //         }
                  //       : null, // 当 _canSend 为 false 时,按钮不可点击
                  //   child: Text('发送'),
                  // ),
                ],
              ),
            ),
          );
        });

        // 定义一个 bool 变量来跟踪按钮状态
        // bool _canSend = false;
      },
    );
  }

  Widget bottomInputView() {
    return Container(
        height: 68.px,
        padding: EdgeInsets.fromLTRB(25.px, 15.px, 0, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
          border: Border(top: BorderSide(color: AppTheme.color_F3F3F3)),
        ),
        alignment: Alignment.topCenter,
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Global().checkLogin(() {
                    Get.to(PublishCommentPage(relType: viewParams.relType!, relId: viewParams.relId!));
                  });
                },
                child: Container(
                  height: 30.px,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xff95A3C4).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 17.px),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/input_e.png',
                        width: 13.5.px,
                      ),
                      SizedBox(
                        width: 9.5.px,
                      ),
                      Expanded(
                        child: Text(
                          '说点什么',
                          style: TextStyle(fontSize: 12.px, color: const Color(0xff9CACC9)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            //点赞
            if (viewParams.relType == 'thread')
              InkWell(
                  onTap: () {
                    Global().checkLogin(() {
                      _likeToggle();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.px),
                    child: Row(
                      children: [
                        Image.asset(
                          viewParams.liked == true ? 'assets/images/praised.png' : 'assets/images/praise.png',
                          width: 13.px,
                          height: 13.px,
                        ),
                        SizedBox(width: 4.px),
                        Text(
                          '${viewParams.likeCount}',
                          style: TextStyle(
                            color: const Color(0xff9cacc9),
                            fontSize: 12.px,
                          ),
                        )
                      ],
                    ),
                  )),
            InkWell(
                onTap: () {
                  Global().checkLogin(() {
                    _favoriteToggle();
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.px),
                  child: Row(
                    children: [
                      Image.asset(
                        viewParams.favoriteState == true ? 'assets/images/stared.png' : 'assets/images/star.png',
                        width: 13.px,
                        height: 13.px,
                      ),
                      SizedBox(width: 4.px),
                      Text(
                        '${viewParams.favoriteCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.px,
                        ),
                      )
                    ],
                  ),
                )),
            InkWell(
                onTap: () {
                  Get.to(CommentListPage(
                    id: viewParams.relId!,
                    relType: viewParams.relType!,
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.px),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/comment.png',
                        width: 13.px,
                        height: 13.px,
                      ),
                      SizedBox(width: 4.px),
                      Text(
                        '${viewParams.commentCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.px,
                        ),
                      )
                    ],
                  ),
                )),
            InkWell(
                // onTap: () {
                // Share.share(
                //   'https://reptile-vue.dexin62.com${widget.viewParams.shareLink}',
                //   subject: widget.viewParams.title,
                // );
                // },
                onTap: _onShare,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.px),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/share.png',
                        width: 13.px,
                        height: 13.px,
                      ),
                      SizedBox(width: 4.px),
                      Text(
                        '${viewParams.shareCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.px,
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ));
  }

  void _likeToggle() {
    NetRequest().contentLike(
        {'relType': viewParams.relType!, 'relId': viewParams.relId!, 'state': viewParams.liked ?? false ? false : true},
        (data) {
      if (_isMounted) {
        if (viewParams.liked == true) {
          viewParams.liked = false;
          viewParams.likeCount = viewParams.likeCount - 1;
        } else {
          viewParams.liked = true;
          viewParams.likeCount = viewParams.likeCount + 1;
        }
        setState(() {});
        EventBusUtil.of.fire(EventRefreshPage(viewParams.relType!));
      }
    });
  }

  void _favoriteToggle() {
    NetRequest().favoriteToggle(viewParams.relType!, viewParams.relId!, !(viewParams.favoriteState ?? false), (data) {
      if (_isMounted) {
        ToastUtils.showToast(viewParams.favoriteState == true ? '取消成功' : '收藏成功');
        if (viewParams.favoriteState == true) {
          viewParams.favoriteState = false;
          viewParams.favoriteCount = viewParams.favoriteCount - 1;
        } else {
          viewParams.favoriteState = true;
          viewParams.favoriteCount = viewParams.favoriteCount + 1;
        }
        setState(() {});
        EventBusUtil.of.fire(EventRefreshPage(viewParams.relType!));
      }
    });
  }

  void _onShare() {
    if (viewParams.relType == 'thread') {
      NetRequest().threadUpCount(viewParams.relId!, (data) async {
        if (_isMounted) {
          await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${viewParams.shareLink}'));
          ToastUtils.showToast('分享成功，链接已复制');

          viewParams.shareCount = viewParams.shareCount + 1;
          setState(() {});
        }
      });
    } else {
      NetRequest().upCount(viewParams.relId!, (data) async {
        if (_isMounted) {
          await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${viewParams.shareLink}'));
          ToastUtils.showToast('分享成功，链接已复制');

          viewParams.shareCount = viewParams.shareCount + 1;
          setState(() {});
        }
      });
    }
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
  String? shareLink; //分享
  List<UploadFile>? files; // 帖子的图片或者视频集合
  int likeCount;
  int favoriteCount;
  int commentCount;
  int shareCount;

  PostBottomViewParams({
    this.postId,
    required this.relId,
    required this.relType,
    this.liked = false,
    this.likeCount = 0,
    this.favoriteState = false,
    this.favoriteCount = 0,
    required this.shareLink,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.title,
    required this.content,
    required this.files,
  });
}
