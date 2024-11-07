import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/forum/media_helper.dart';
import 'package:holdem/page/forum/page_comment_input.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';

import '../mine/login_helper.dart';

class CommentItem extends StatefulWidget {
  final CommentBean commentBean;
  final bool isReply;

  const CommentItem({super.key, required this.commentBean, this.isReply = false});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isReplyExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BorderAvatar(avatar: widget.commentBean.user != null ? widget.commentBean.user!.avatar! : ''),
        SizedBox(width: 7.px),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.commentBean.user != null ? widget.commentBean.user!.nickname! : '',
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 12.px,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3.px),
              Text(
                widget.commentBean.contentStr ?? '',
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 12.px,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 10.px),
                itemCount: widget.commentBean.files?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      MediaHelper().imagePerView(
                        context,
                        widget.commentBean.files!.map((e) => e.url ?? '').toList(),
                        index,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.commentBean.files?[index].url ?? '',
                        placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                        errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.px),
              Row(
                children: [
                  Text(
                    widget.commentBean.createdAt != null
                        ? DateFormat('MM/d').format(widget.commentBean.createdAt!)
                        : '',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.px,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isReply) ...[
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
                            widget.commentBean.likeCount = widget.commentBean.liked! ? count + 1 : count - 1;
                          });
                        });
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            widget.commentBean.liked ?? false
                                ? 'assets/images/praised.png'
                                : 'assets/images/praise.png',
                            width: 11.px,
                          ),
                          SizedBox(width: 6.px),
                          Text(
                            widget.commentBean.likeCount!.toString(),
                            style: TextStyle(
                              color: const Color(0xff9CACC9),
                              fontSize: 10.px,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 32.px),
                    GestureDetector(
                      onTap: () {
                        Global().checkLogin(() {
                          Get.to(CommentInputPage(relType: 'comment', relId: widget.commentBean.id!));
                        });
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/comment.png',
                            width: 13.px,
                          ),
                          SizedBox(width: 6.px),
                          Text(
                            widget.commentBean.replyCount!.toString(),
                            style: TextStyle(
                              color: const Color(0xff9CACC9),
                              fontSize: 10.px,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (widget.commentBean.replies?.isNotEmpty == true) ...[
                SizedBox(height: 17.px),
                Padding(
                  padding: EdgeInsets.only(left: 8.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...List.generate(
                        _isReplyExpanded
                            ? widget.commentBean.replies!.length
                            : min(widget.commentBean.replies!.length, 2),
                        (index) {
                          final reply = widget.commentBean.replies![index];
                          return Padding(
                            padding: EdgeInsets.only(top: 10.px),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BorderAvatar(avatar: reply.user?.avatar ?? ''),
                                SizedBox(width: 7.px),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        reply.user?.nickname ?? '',
                                        style: TextStyle(
                                          color: const Color(0xff2a2a2a),
                                          fontSize: 12.px,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 3.px),
                                      Text(
                                        reply.contentStr ?? '',
                                        style: TextStyle(
                                          color: const Color(0xff2a2a2a),
                                          fontSize: 12.px,
                                        ),
                                      ),
                                      SizedBox(height: 10.px),
                                      Row(
                                        children: [
                                          Text(
                                            reply.createdAt != null ? DateFormat('MM/d').format(reply.createdAt!) : '',
                                            style: TextStyle(
                                              color: const Color(0xff9CACC9),
                                              fontSize: 10.px,
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              NetRequest().contentLike({
                                                'relType': 'comment',
                                                'relId': reply.id!,
                                                'state': reply.liked! ? false : true
                                              }, (data) {
                                                setState(() {
                                                  reply.liked = !reply.liked!;
                                                  int count = reply.likeCount!;
                                                  reply.likeCount = reply.liked! ? count + 1 : count - 1;
                                                });
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  reply.liked ?? false
                                                      ? 'assets/images/praised.png'
                                                      : 'assets/images/praise.png',
                                                  width: 11.px,
                                                ),
                                                SizedBox(width: 6.px),
                                                Text(
                                                  reply.likeCount!.toString(),
                                                  style: TextStyle(
                                                    color: const Color(0xff9CACC9),
                                                    fontSize: 10.px,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if ((widget.commentBean.replies?.length ?? 0) > 2)
                        Container(
                          height: 24.px,
                          margin: EdgeInsets.only(top: 10.px),
                          child: GestureDetector(
                            onTap: () {
                              _isReplyExpanded = !_isReplyExpanded;
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                if (_isReplyExpanded)
                                  const Spacer()
                                else
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.px),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff2f4f6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '查看全部${widget.commentBean.replies?.length ?? 0}条回复',
                                      style: TextStyle(
                                        color: const Color(0xff3B5078),
                                        fontSize: 12.px,
                                      ),
                                    ),
                                  ),
                                if (_isReplyExpanded)
                                  Row(
                                    children: [
                                      Text(
                                        '收起',
                                        style: TextStyle(
                                          color: const Color(0xff3B5078),
                                          fontSize: 12.px,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_up),
                                    ],
                                  )
                                else
                                  const Spacer()
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Container(
                height: 1.px,
                margin: EdgeInsets.symmetric(vertical: 16.5.px),
                color: const Color(0xffe6e6e6),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class BorderAvatar extends StatelessWidget {
  const BorderAvatar({
    super.key,
    required this.avatar,
    this.avatarSize = 34,
  });

  final String avatar;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (avatarSize + 2).px,
      height: (avatarSize + 2).px,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((avatarSize / 2).px),
      ),
      child: ClipOval(
        child: LoginHelper().getUserAvatar(
          avatar,
          avatarSize.px,
          avatarSize.px,
        ),
      ),
    );
  }
}
