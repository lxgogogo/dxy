import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/page_replies.dart';
import 'package:holdem/page/forum/page_comment_input.dart';
import 'package:holdem/page/mine/page_login.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';

import '../mine/login_helper.dart';

class CommentItem extends StatefulWidget {
  CommentBean commentBean;
  bool isReply;
  CommentItem({super.key, required this.commentBean, this.isReply = false});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 40.px,
          height: 40.px,
          child: ClipOval(
            child: LoginHelper().getUserAvatar(
                widget.commentBean.user != null
                    ? widget.commentBean.user!.avatar!
                    : '',
                40.px,
                40.px),
            // Image.network(
            //   widget.commentBean.user != null ? widget.commentBean.user!.avatar! :'',
            //   width: 40.px,
            //   height: 40.px,
            //   // fit: BoxFit.cover,
            // ),
          ),
        ),
        SizedBox(
          width: 10.px,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              widget.commentBean.user != null
                  ? widget.commentBean.user!.nickname!
                  : '',
              style: TextStyle(color: Color(0xff3B5078), fontSize: 13.px),
            ),
            SizedBox(height: 3.px),
            Text(
              widget.commentBean.contentStr ?? '',
              style: TextStyle(
                  color: const Color(0xff333333), fontSize: 14.px, height: 1.5),
            ),
            if (widget.commentBean.replies != null &&
                widget.commentBean.replies!.length > 0)
              SizedBox(
                height: 5.px,
              ),
            if (widget.commentBean.replies != null &&
                widget.commentBean.replies!.length > 0)
              Container(
                  padding: EdgeInsets.only(left: 9.px),
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              width: 3.px,
                              color: Colors.black.withOpacity(0.05)))),
                  child: Container(
                    padding: EdgeInsets.all(10.px),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.all(Radius.circular(10.px))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...List.generate(widget.commentBean.replies!.length,
                            (index) {
                          Reply reply = widget.commentBean.replies![index];
                          return Text(
                              '${reply.user!.nickname}：${reply.content}',
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 14.px,
                                  height: 2.0));
                        }),
                        widget.commentBean.replyCount! > 2
                            ? GestureDetector(
                                onTap: () {
                                  Get.to(RepliesPage(
                                      id: widget.commentBean.id!,
                                      commentBean: widget.commentBean));
                                  // Get.to(CommentInputPage(
                                  //     relType: 'comment',
                                  //     relId: widget.commentBean.id!));
                                },
                                child: Text(
                                  '查看全部${widget.commentBean.replyCount}条回复',
                                  style: TextStyle(
                                      color: const Color(0xff3B5078),
                                      fontSize: 14.px),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )),
            // Row(children: [
            //   Container(
            //     width: 3.px,
            //     color: Colors.black.withOpacity(0.05),
            //   ),
            //   Expanded(child: Container(
            //     child: Column(children: [
            //       Text('用户1：说的好'),
            //       Text('用户2：说的好回复评论说的好回复评论说的好回复评论')
            //     ],),
            //   ))
            //   ,
            // ],),
            SizedBox(
              height: 10.px,
            ),
            Row(
              children: [
                Text(
                  widget.commentBean.createdAt != null
                      ? DateFormat('MM-dd HH:mm')
                          .format(widget.commentBean.createdAt!)
                      : '',
                  style: TextStyle(color: Color(0xff999999), fontSize: 14.px),
                ),
                const Spacer(),
                if (!widget.isReply)
                  GestureDetector(
                    onTap: () {
                      if (!Global().hasLogin) {
                        Get.to(LoginPage());
                        return;
                      }
                      //跳转评论输入页面
                      Get.to(CommentInputPage(
                          relType: 'comment', relId: widget.commentBean.id!));
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/reply.png',
                          width: 20.px,
                          height: 20.px,
                        ),
                        SizedBox(
                          width: 5.px,
                        ),
                        Text(
                          widget.commentBean.replyCount!.toString(),
                          style: TextStyle(
                            color: const Color(0xff999999),
                            fontSize: 14.px,
                          ),
                        )
                      ],
                    ),
                  ),
                SizedBox(
                  width: 15.px,
                ),
                if (!widget.isReply)
                  GestureDetector(
                    onTap: () {
                      NetRequest().contentLike({
                        'relType': 'comment',
                        'relId': widget.commentBean.id!,
                        'state': widget.commentBean.liked! ? false : true
                      }, (data) {
                        setState(() {
                          widget.commentBean.liked = !widget.commentBean.liked!;
                          int count = widget.commentBean.likeCount!;
                          widget.commentBean.likeCount =
                              widget.commentBean.liked! ? count + 1 : count - 1;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          widget.commentBean.liked ?? false
                              ? 'assets/images/praised.png'
                              : 'assets/images/praise.png',
                          width: 18.px,
                          height: 18.px,
                        ),
                        SizedBox(
                          width: 5.px,
                        ),
                        Text(
                          widget.commentBean.likeCount!.toString(),
                          style: TextStyle(
                            color: const Color(0xff999999),
                            fontSize: 14.px,
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(vertical: 20.px),
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ))
      ],
    );
  }
}
