import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
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
import '../utils/date_util.dart';
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
    final showReport = /*widget.relType == 'thread' &&*/
        !UserStore.of.isMe(widget.commentBean.user?.id);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BorderAvatar(
          avatar: widget.commentBean.user != null
              ? widget.commentBean.user!.avatar!
              : '',
          borderWidth: 0,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    widget.commentBean.user != null
                        ? widget.commentBean.user!.nickname!
                        : '',
                    style: TextStyle(
                      color: '#333333'.hexColor,
                      fontSize: 12.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (showReport)
                    GestureDetector(
                        onTap: () {
                          if (widget.commentBean.id != null &&
                              widget.commentBean.user?.id != null) {
                            UserStore.of.checkLogin(() {
                              _onReport(widget.commentBean.id!,
                                  widget.commentBean.user!.id!);
                            });
                          }
                        },
                        child: Icon(
                          Icons.more_horiz,
                          color: '#333333'.hexColor.withOpacity(0.7),
                        )),
                ],
              ),
              SizedBox(height: 2.w),
              HtmlWidget(
                widget.commentBean.contentStr ?? '',
                textStyle: TextStyle(
                  color: '#333333'.hexColor.withOpacity(0.7),
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
                          widget.commentBean.files!
                              .map((e) => e.url ?? '')
                              .toList(),
                          index,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.commentBean.files?[index].url ?? '',
                          placeholder: (context, url) => Assets
                              .images.imageLoadingDef
                              .image(fit: BoxFit.fill),
                          errorWidget: (context, url, error) => Assets
                              .images.imageLoadingDef
                              .image(fit: BoxFit.fill),
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
                        ? '${DateUtil.formatDateAlias(widget.commentBean.createdAt!.millisecondsSinceEpoch)}发布'
                        : '',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.w,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isReply) ...[
                    CountLikeAni(
                      count:
                          widget.commentBean.likeCount?.abbreviateNumber ?? '0',
                      liked: widget.commentBean.liked ?? false,
                      usePlaceHolder: false,
                      likeWidget: widget.commentBean.liked ?? false
                          ? Container(
padding: EdgeInsets.all(4.w),
                            child: SvgPicture.asset(
                                Assets.svg.liked,
                                color: '#567BF6'.hexColor.withOpacity(0.7),

                              ),
                          )
                          : Container(
                        padding: EdgeInsets.all(4.w),
                            child: SvgPicture.asset(
                                Assets.svg.like,

                                color: '#333333'.hexColor.withOpacity(0.7),
                              ),
                          ),
                      onToggleLike: () async {
                        final data = await NetRequest().newContentLike({
                          'relType': 'comment',
                          'relId': widget.commentBean.id!,
                          'state': widget.commentBean.liked! ? false : true
                        });
                        if (data is int) {
                          widget.commentBean.liked = !widget.commentBean.liked!;
                          int count = widget.commentBean.likeCount!;
                          widget.commentBean.likeCount =
                              widget.commentBean.liked! ? count + 1 : count - 1;
                          setState(() {});
                          return true;
                        }
                        return false;
                      },
                    ),
                    SizedBox(
                      width: 16.w,
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
                      child: CountReply(
                        count:
                            widget.commentBean.replyCount?.abbreviateNumber ??
                                '0',
                        usePlaceHolder: false,
                        iconWidget: SvgPicture.asset(
                          Assets.svg.feedComment,
                          color: '#333333'.hexColor.withOpacity(0.7),
                          width: 14.w,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (widget.commentBean.replies?.isNotEmpty == true) ...[
                SizedBox(height: 17.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(
                      widget.commentBean.replies!.length,
                      (index) {
                        final reply = widget.commentBean.replies![index];
                        final showReplyReport = /*widget.relType == 'thread' &&*/
                            !UserStore.of.isMe(reply.user?.id);
                        return Padding(
                          padding: EdgeInsets.only(top: 10.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BorderAvatar(
                                avatar: reply.user?.avatar ?? '',
                                borderWidth: 0,
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          reply.user?.nickname ?? '',
                                          style: TextStyle(
                                            color: '#333333'.hexColor,
                                            fontSize: 12.w,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (showReplyReport)
                                          GestureDetector(
                                              onTap: () {
                                                if (widget.commentBean.id !=
                                                        null &&
                                                    widget.commentBean.user
                                                            ?.id !=
                                                        null) {
                                                  UserStore.of.checkLogin(() {
                                                    _onReport(
                                                        widget.commentBean.id!,
                                                        widget.commentBean.user!
                                                            .id!);
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                Icons.more_horiz,
                                                color: '#333333'
                                                    .hexColor
                                                    .withOpacity(0.7),
                                              )),
                                      ],
                                    ),
                                    SizedBox(height: 2.w),
                                    HtmlWidget(
                                      reply.contentStr ?? '',
                                      textStyle: TextStyle(
                                        color:
                                            '#333333'.hexColor.withOpacity(0.7),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.w),
                                    Row(
                                      children: [
                                        Text(
                                          widget.commentBean.createdAt != null
                                              ? '${DateUtil.formatDateAlias(reply.createdAt!.millisecondsSinceEpoch)}发布'
                                              : '',
                                          style: TextStyle(
                                            color: const Color(0xff9CACC9),
                                            fontSize: 10.w,
                                          ),
                                        ),
                                        const Spacer(),
                                        CountLikeAni(
                                          count:
                                              reply.likeCount.abbreviateNumber,
                                          liked: reply.liked ?? false,
                                          usePlaceHolder: false,
                                          onToggleLike: () async {
                                            final data = await NetRequest()
                                                .newContentLike({
                                              'relType': 'comment',
                                              'relId': reply.id!,
                                              'state':
                                                  reply.liked! ? false : true
                                            });
                                            if (data is int) {
                                              reply.liked = !reply.liked!;
                                              int count = reply.likeCount!;
                                              reply.likeCount = reply.liked!
                                                  ? count + 1
                                                  : count - 1;
                                              setState(() {});
                                              return true;
                                            }
                                            return false;
                                          },
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
                        margin: EdgeInsets.only(top: 10.w),
                        child: Row(
                          children: [
                            if ((widget.commentBean.replyCount ?? 0) >
                                (widget.commentBean.replies?.length ?? 0)) ...[
                              GestureDetector(
                                onTap: () {
                                  getReplyList();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff2f4f6),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    '查看全部${min(pageSize, (widget.commentBean.replyCount ?? 0) - (widget.commentBean.replies?.length ?? 0))}条回复>',
                                    style: TextStyle(
                                      color: '#333333'.hexColor,
                                      fontSize: 14.w,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  pageNum = 1;
                                  widget.commentBean.replies = List.of(
                                      widget.commentBean.replies?.take(2) ??
                                          []);
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
              ],
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.w),
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
    this.avatarSize = 30,
    this.borderWidth = 2,
  });

  final String avatar;
  final double avatarSize;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (avatarSize + borderWidth).w,
      height: (avatarSize + borderWidth).w,
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
          placeholder: (context, url) =>
              Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
          errorWidget: (context, url, error) =>
              Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
        ),
      ),
    );
  }
}
