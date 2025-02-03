import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment_input/comment_input_screen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/media_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/report_sheet.dart';
import 'package:intl/intl.dart';

import '../services/index.dart';
import '../stores/config_store.dart';
import '../utils/toast_utils.dart';

class CommentItem extends StatefulWidget {
  final CommentBean commentBean;
  final bool isReply;
  final String relType;

  const CommentItem({
    super.key,
    required this.commentBean,
    this.relType = '',
    this.isReply = false,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final int pageSize = 10;

  int pageNum = 1;
  bool inFetching = false;

  @override
  void didUpdateWidget(covariant CommentItem oldWidget) {
    if (oldWidget.commentBean != widget.commentBean) {
      pageNum = 1;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onReport(int id, int userId) async {
    final reportTypes = await ConfigStore.of.getReportTypes();
    Get.bottomSheet(
      ReportSheet(
        reportTypes: reportTypes,
        onReport: (int index) async {
          try {
            final res = await CommonService.of.reportCreate(
              'comment',
              id,
              userId,
              reason: reportTypes[index].value,
            );
            if (res.isSuccess) {
              ToastUtils.showToast('举报成功，我们将会在24小时内受理');
            }
          } finally {
            Get.back();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showReport = /*widget.relType == 'thread' &&*/ !UserStore.of.isMe(widget.commentBean.user?.id);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BorderAvatar(avatar: widget.commentBean.user != null ? widget.commentBean.user!.avatar! : ''),
        SizedBox(width: 7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.commentBean.user != null ? widget.commentBean.user!.nickname! : '',
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 12.w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.w),
              HtmlWidget(
                widget.commentBean.contentStr ?? '',
                textStyle: TextStyle(
                  color: const Color(0xff666666),
                  fontSize: 12.sp,
                ),
              ),
              if (widget.commentBean.files?.isNotEmpty == true)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 8.w),
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
                          placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                          errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 8.w),
              Row(
                children: [
                  Text(
                    widget.commentBean.createdAt != null
                        ? DateFormat('MM/d').format(widget.commentBean.createdAt!)
                        : '',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.w,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isReply) ...[
                    CountLikeAni(
                      count: widget.commentBean.likeCount?.abbreviateNumber ?? '0',
                      liked: widget.commentBean.liked ?? false,
                      onToggleLike: () {
                        return NetRequest().contentLike({
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
                    ),
                    GestureDetector(
                      onTap: () {
                        UserStore.of.checkLogin(() {
                          Get.bottomSheet(
                            CommentInputScreen(
                              relType: widget.commentBean.relType ?? '',
                              relId: widget.commentBean.id ?? 0,
                            ),
                          );
                        });
                      },
                      child: CountComment(
                        count: widget.commentBean.replyCount?.abbreviateNumber ?? '0',
                        usePlaceHolder: showReport,
                      ),
                    ),
                    if (showReport)
                      GestureDetector(
                        onTap: () {
                          if (widget.commentBean.id != null && widget.commentBean.user?.id != null) {
                            UserStore.of.checkLogin(() {
                              _onReport(widget.commentBean.id!, widget.commentBean.user!.id!);
                            });
                          }
                        },
                        child: Image.asset(
                          'assets/images/report.png',
                          width: 12.w,
                        ),
                      ),
                  ],
                ],
              ),
              if (widget.commentBean.replies?.isNotEmpty == true) ...[
                SizedBox(height: 17.w),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...List.generate(
                        widget.commentBean.replies!.length,
                        (index) {
                          final reply = widget.commentBean.replies![index];
                          final showReplyReport = /*widget.relType == 'thread' &&*/ !UserStore.of.isMe(reply.user?.id);
                          return Padding(
                            padding: EdgeInsets.only(top: 10.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BorderAvatar(avatar: reply.user?.avatar ?? ''),
                                SizedBox(width: 7.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        reply.user?.nickname ?? '',
                                        style: TextStyle(
                                          color: const Color(0xff2a2a2a),
                                          fontSize: 12.w,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2.w),
                                      HtmlWidget(
                                        reply.contentStr ?? '',
                                        textStyle: TextStyle(
                                          color: const Color(0xff666666),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(height: 8.w),
                                      Row(
                                        children: [
                                          Text(
                                            reply.createdAt != null ? DateFormat('MM/d').format(reply.createdAt!) : '',
                                            style: TextStyle(
                                              color: const Color(0xff9CACC9),
                                              fontSize: 10.w,
                                            ),
                                          ),
                                          const Spacer(),
                                          CountLikeAni(
                                            count: reply.likeCount.abbreviateNumber,
                                            liked: reply.liked ?? false,
                                            usePlaceHolder: showReplyReport,
                                            onToggleLike: ()  {
                                              return NetRequest().contentLike({
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
                                          ),
                                          if (showReplyReport)
                                            GestureDetector(
                                              onTap: () {
                                                if (reply.id != null && reply.user?.id != null) {
                                                  UserStore.of.checkLogin(() {
                                                    _onReport(reply.id!, reply.user!.id!);
                                                  });
                                                }
                                              },
                                              child: Image.asset(
                                                'assets/images/report.png',
                                                width: 12.w,
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
                      if ((widget.commentBean.replyCount ?? 0) > 2)
                        Container(
                          height: 24.w,
                          margin: EdgeInsets.only(top: 10.w),
                          child: Row(
                            children: [
                              if ((widget.commentBean.replyCount ?? 0) > (widget.commentBean.replies?.length ?? 0)) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff2f4f6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '查看全部${min(pageSize, (widget.commentBean.replyCount ?? 0) - (widget.commentBean.replies?.length ?? 0))}条回复',
                                    style: TextStyle(
                                      color: const Color(0xff3B5078),
                                      fontSize: 12.w,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    getReplyList();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '展开',
                                        style: TextStyle(
                                          color: const Color(0xff3B5078),
                                          fontSize: 12.w,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                )
                              ] else ...[
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    pageNum = 1;
                                    widget.commentBean.replies = List.of(widget.commentBean.replies?.take(2) ?? []);
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '收起',
                                        style: TextStyle(
                                          color: const Color(0xff3B5078),
                                          fontSize: 12.w,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_up),
                                    ],
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Container(
                height: 1.w,
                margin: EdgeInsets.symmetric(vertical: 16.5.w),
                color: const Color(0xffe6e6e6),
              ),
            ],
          ),
        )
      ],
    );
  }

  getReplyList() {
    if (inFetching) return;
    inFetching = true;
    NetRequest().replyList(
      pageNum,
      pageSize,
      widget.commentBean.id,
      widget.commentBean.relType,
      (data) {
        CommentList commentList = CommentList.fromJson(data);
        if (mounted) {
          if (pageNum == 1) {
            widget.commentBean.replies = commentList.list ?? [];
          } else {
            widget.commentBean.replies?.addAll(commentList.list ?? []);
          }
          pageNum++;
          setState(() {});
        }
        inFetching = false;
      },
      (msg) {
        inFetching = false;
      },
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
      width: (avatarSize + 2).w,
      height: (avatarSize + 2).w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((avatarSize / 2).w),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatar,
          width: avatarSize.w,
          height: avatarSize.w,
          fit: BoxFit.cover,
          cacheKey: avatar,
          memCacheWidth: avatarSize.toInt(),
          memCacheHeight: avatarSize.toInt(),
          placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
          errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
        ),
      ),
    );
  }
}
