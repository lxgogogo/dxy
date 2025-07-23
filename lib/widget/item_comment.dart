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
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/media_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/dialog_common.dart';
import 'package:holdem/widget/report_sheet.dart';

import '../routes/app_pages.dart';
import '../services/index.dart';
import '../stores/config_store.dart';
import '../utils/date_util.dart';
import '../utils/dialog_util.dart';
import '../utils/track_utils.dart';

class CommentItem extends StatefulWidget {
  final List<CommentBean> commentsData;
  final CommentBean commentBean;
  final bool isReply;
  final String relType;
  final SourceType sourceType;
  final int? sourceId;
  final Function followOnTap;

  const CommentItem({
    super.key,
    required this.commentsData,
    required this.commentBean,
    required this.sourceType,
    required this.followOnTap,
    this.sourceId,
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
              DialogUtil.showToast('举报成功，我们将会在24小时内受理');
            }
          } finally {
            Get.back();
          }
        },
      ),
    );
  }

  void _followToggle({int type = 0, var data}) async {
    if (!UserStore.of.isLogin) {
      Get.toNamed(Routes.login);
      return;
    }
    String title = '';
    String content = '';
    String name = '';
    int id = 0;
    bool followed = false;
    if (type == 0) {
      id = widget.commentBean.user?.id ?? 0;
      followed = !(widget.commentBean.followed ?? false);
      name = widget.commentBean.user?.nickname ?? '';
      title = '关注';
      content = '确定关注 $name 吗?';
      if (widget.commentBean.followed == true) {
        title = '取消关注';
        content = '确定取消关注 $name 吗?';
      }
    } else {
      id = data.user?.id ?? 0;
      followed = !(data.followed ?? false);
      name = data.user?.nickname ?? '';
      title = '关注';
      content = '确定关注 $name 吗?';
      if (data.followed == true) {
        title = '取消关注';
        content = '确定取消关注 $name 吗?';
      }
    }
    if (followed) {
      _submitFollowData(id, followed, () {
        if (type == 0) {
          widget.commentBean.followed = followed;
        } else {
          data.followed = followed;
        }
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => CommonDialog(
            title: title,
            content: content,
            confirmText: '确认',
            onConfirm: () {
              Get.close(0);
              _submitFollowData(id, followed, () {
                if (type == 0) {
                  widget.commentBean.followed = followed;
                } else {
                  data.followed = followed;
                }
                if (mounted) {
                  setState(() {});
                }
              });
            },
          ));
    }

  }

  void _submitFollowData(id, followed, Function callBack) {
    UserStore.of.checkLogin(() {
      NetRequest().followerToggle(id, followed, (data) {
        if (followed) {
          DialogUtil.showToast('关注成功');
        } else {
          DialogUtil.showToast('取消关注成功');
        }
        callBack();
        _updateFollowData(id, followed);
      });
    });
  }

  void _updateFollowData(int id, bool followed) {
    for (final m in widget.commentsData) {
      if (m.user?.id == id) {
        m.followed = followed;
      }
    }
    for (final m in widget.commentBean.replies ?? []) {
      if (m.user?.id == id) {
        m.followed = followed;
      }
    }
    if (mounted) {
      setState(() {});
    }
    widget.followOnTap();
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
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.commentBean.user?.nickname ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if ((widget.commentBean.user?.id ?? 0) != 0)
                        Visibility(
                          visible: !UserStore.of
                              .isMe(widget.commentBean.user?.id), //
                          child: GestureDetector(
                            onTap: () async {
                              _followToggle(type: 0);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 4.w),
                              child: Container(
                                width: 56.w,
                                height: 22.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6.w)),
                                    color: widget.commentBean.followed == true
                                        ? ColorStyle.c333333.withOpacity(0.1)
                                        : ColorStyle.c557BF6.withOpacity(0.1)),
                                child: Text(
                                    widget.commentBean.followed == true
                                        ? '已关注'
                                        : '关注',
                                    style: TextStyle(
                                      color: widget.commentBean.followed == true
                                          ? AppTheme.color_333333
                                          : '#557BF6'.hexColor,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                      child: SvgPicture.asset(
                        Assets.svg.more,
                        width: 12.w,
                        height: 12.w,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.w),
              HtmlWidget(
                widget.commentBean.contentStr ?? '',
                textStyle: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                ),
              ),
              if (widget.commentBean.files?.isNotEmpty == true)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 8.w),
                  itemCount: widget.commentBean.files?.length ?? 0,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.w,
                    mainAxisSpacing: 5.w,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        MediaHelper().imagePerView(
                          context,
                          widget.commentBean.files
                                  ?.map((e) => e.url ?? '')
                                  .toList() ??
                              [],
                          index,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
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
              SizedBox(height: 4.w),
              Row(
                children: [
                  Text(
                    widget.commentBean.createdAt != null
                        ? '${DateUtil.formatDateAlias3(widget.commentBean.createdAt!.millisecondsSinceEpoch, hasHM: true)}发布'
                        : '',
                    style: TextStyle(
                      color: '#999999'.hexColor,
                      fontSize: 10.sp,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isReply) ...[
                    CountLikeAni(
                      count:
                          widget.commentBean.likeCount?.abbreviateNumber ?? '0',
                      liked: widget.commentBean.liked ?? false,
                      usePlaceHolder: false,
                      likeWidget: Center(
                        child: SvgPicture.asset(
                          widget.commentBean.liked == true
                              ? Assets.svg.liked
                              : Assets.svg.like,
                          color: '#999999'.hexColor,
                          width: 14.w,
                          height: 14.w,
                        ),
                      ),
                      onToggleLike: () async {
                        final data = await NetRequest().newContentLike({
                          'relType': 'comment',
                          'relId': widget.commentBean.id,
                          'state':
                              widget.commentBean.liked == true ? false : true
                        });
                        if (data is int) {
                          widget.commentBean.liked = !widget.commentBean.liked!;
                          int count = widget.commentBean.likeCount!;
                          widget.commentBean.likeCount =
                              widget.commentBean.liked! ? count + 1 : count - 1;
                          if (widget.commentBean.liked == true) {
                            DialogUtil.showToast('点赞成功');
                            switch (widget.sourceType) {
                              case SourceType.video:
                                TrackUtils.trackEvent(
                                    userLogType: '103008',
                                    params: widget.sourceId);
                                break;
                              case SourceType.course:
                                TrackUtils.trackEvent(
                                    userLogType: '105007',
                                    params: widget.sourceId);
                                break;
                              case SourceType.book:
                                TrackUtils.trackEvent(
                                    userLogType: '107008',
                                    params: widget.sourceId);
                                break;
                              case SourceType.feed:
                                TrackUtils.trackEvent(
                                    userLogType: '109007',
                                    params: widget.sourceId);
                                break;
                              case SourceType.tool:
                              // TODO: Handle this case.
                            }
                          } else {
                            DialogUtil.showToast('取消点赞成功');
                          }
                          setState(() {});
                          return true;
                        }
                        return false;
                      },
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () {
                        UserStore.of.checkLogin(() {
                          Get.bottomSheet(
                            CommentInputScreen(
                              relType: widget.commentBean.relType ?? '',
                              relId: widget.commentBean.id ?? 0,
                              sourceType: widget.sourceType,
                              sourceId: widget.sourceId,
                            ),
                          );
                        });
                      },
                      child: (widget.commentBean.replyCount ?? 0) > 0
                          ? CountReply(
                              count: widget.commentBean.replyCount
                                      ?.abbreviateNumber ??
                                  '0',
                              usePlaceHolder: false,
                              iconWidget: SvgPicture.asset(
                                Assets.svg.feedComment,
                                color: '#999999'.hexColor,
                                width: 14.w,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    Assets.svg.feedComment,
                                    color: '#999999'.hexColor,
                                    width: 14.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '回复',
                                    style: TextStyle(
                                      color: '#999999'.hexColor,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ],
              ),
              if (widget.commentBean.replies?.isNotEmpty == true) ...[
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
                          padding: EdgeInsets.only(top: 12.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BorderAvatar(
                                avatar: reply.user?.avatar ?? '',
                                borderWidth: 0,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              reply.user?.nickname ?? '',
                                              style: TextStyle(
                                                color: '#333333'.hexColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if ((reply.user?.id ?? 0) != 0)
                                              Visibility(
                                                visible: !UserStore.of
                                                    .isMe(reply.user?.id),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    _followToggle(
                                                        type: 0,
                                                        data: reply);
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 4.w),
                                                    child: Container(
                                                      width: 56.w,
                                                      height: 22.w,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          6.w)),
                                                          color: reply.followed ==
                                                                  true
                                                              ? ColorStyle
                                                                  .c333333
                                                                  .withOpacity(
                                                                      0.1)
                                                              : ColorStyle
                                                                  .c557BF6
                                                                  .withOpacity(
                                                                      0.1)),
                                                      child: Text(
                                                        reply.followed == true
                                                            ? '已关注'
                                                            : '关注',
                                                        style: TextStyle(
                                                          color: reply
                                                                      .followed ==
                                                                  true
                                                              ? AppTheme
                                                                  .color_333333
                                                              : '#557BF6'
                                                                  .hexColor,
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const Spacer(),
                                        if (showReplyReport)
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.commentBean.id !=
                                                      null &&
                                                  widget.commentBean.user?.id !=
                                                      null) {
                                                UserStore.of.checkLogin(() {
                                                  _onReport(
                                                      widget.commentBean.id!,
                                                      widget.commentBean.user!
                                                          .id!);
                                                });
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              Assets.svg.more,
                                              width: 12.w,
                                              height: 12.w,
                                            ),
                                          ),
                                      ],
                                    ),
                                    HtmlWidget(
                                      reply.contentStr ?? '',
                                      textStyle: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    // SizedBox(height: 8.w),
                                    Row(
                                      children: [
                                        Text(
                                          widget.commentBean.createdAt != null
                                              ? '${DateUtil.formatDateAlias3(reply.createdAt!.millisecondsSinceEpoch)}发布'
                                              : '',
                                          style: TextStyle(
                                            color: '#999999'.hexColor,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        CountLikeAni(
                                          count:
                                              reply.likeCount.abbreviateNumber,
                                          liked: reply.liked ?? false,
                                          likeWidget: Center(
                                            child: SvgPicture.asset(
                                              reply.liked == true
                                                  ? Assets.svg.liked
                                                  : Assets.svg.like,
                                              color: '#999999'.hexColor,
                                              width: 14.w,
                                              height: 14.w,
                                            ),
                                          ),
                                          usePlaceHolder: false,
                                          onToggleLike: () async {
                                            final data = await NetRequest()
                                                .newContentLike({
                                              'relType': 'comment',
                                              'relId': reply.id,
                                              'state': reply.liked == true
                                                  ? false
                                                  : true
                                            });
                                            if (data is int) {
                                              reply.liked = !reply.liked!;
                                              int count = reply.likeCount!;
                                              reply.likeCount = reply.liked!
                                                  ? count + 1
                                                  : count - 1;
                                              if (reply.liked == true) {
                                                DialogUtil.showToast('点赞成功');
                                                switch (widget.sourceType) {
                                                  case SourceType.video:
                                                    TrackUtils.trackEvent(
                                                        userLogType: '103009',
                                                        params:
                                                            widget.sourceId);
                                                    break;
                                                  case SourceType.course:
                                                    TrackUtils.trackEvent(
                                                        userLogType: '105008',
                                                        params:
                                                            widget.sourceId);
                                                    break;
                                                  case SourceType.book:
                                                    TrackUtils.trackEvent(
                                                        userLogType: '107009',
                                                        params:
                                                            widget.sourceId);
                                                    break;
                                                  case SourceType.feed:
                                                    TrackUtils.trackEvent(
                                                        userLogType: '109008',
                                                        params:
                                                            widget.sourceId);
                                                    break;
                                                  case SourceType.tool:
                                                  // TODO: Handle this case.
                                                }
                                              } else {
                                                DialogUtil.showToast('取消点赞成功');
                                              }
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
                        margin: EdgeInsets.only(left: 38.w, top: 4.w),
                        child: Row(
                          children: [
                            if ((widget.commentBean.replyCount ?? 0) >
                                (widget.commentBean.replies?.length ?? 0)) ...[
                              GestureDetector(
                                onTap: () {
                                  getReplyList();
                                },
                                child: Container(
                                  height: 22.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: '#333333'.hexColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '查看全部回复',
                                        style: TextStyle(
                                          color: '#333333'.hexColor,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        Assets.svg.iconArrowRight,
                                        width: 14.w,
                                        height: 14.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: () {
                                  pageNum = 1;
                                  widget.commentBean.replies = List.of(
                                      widget.commentBean.replies?.take(2) ??
                                          []);
                                  setState(() {});
                                },
                                child: Container(
                                  height: 22.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff2f4f6),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '收起',
                                        style: TextStyle(
                                          color: '#333333'.hexColor,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        Assets.svg.iconArrowUp,
                                        width: 14.w,
                                        height: 14.w,
                                      ),
                                    ],
                                  ),
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
          // cacheKey: avatar,
          // memCacheWidth: avatarSize.toInt(),
          // memCacheHeight: avatarSize.toInt(),
          placeholder: (context, url) =>
              Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
          errorWidget: (context, url, error) =>
              Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
        ),
      ),
    );
  }
}
