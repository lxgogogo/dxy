import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/env.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/count_widget.dart';

import '../model/user.dart';
import '../page/comment_publish/comment_publish_screen.dart';
import '../page/feed_detail/feed_detail_screen.dart';
import '../page/mine/login_helper.dart';
import '../utils/toast_utils.dart';

class FeedDetailBottomView extends StatefulWidget {
  final List<TagModel> tagList;
  final PostBottomViewParams viewParams;

  const FeedDetailBottomView({
    Key? key,
    required this.viewParams,
    this.tagList = const [],
  }) : super(key: key);

  @override
  State createState() => _FeedDetailBottomViewState();
}

class _FeedDetailBottomViewState extends State<FeedDetailBottomView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 16.w),
      child: Column(

        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.tagList.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: TagListView(
                tagList: widget.tagList,
              ),
            ),
          Container(
            padding: EdgeInsets.only(top: 10.w, bottom: 12.w),
            decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                border: Border(
                  top: BorderSide(color: const Color(0xffE5E5E5), width: 0.5.w),
                )),
            alignment: Alignment.topCenter,
            child: Row(
              children: <Widget>[
                SizedBox(width: 16.w),
                if (widget.viewParams.relType == NetRequest.COMMENT_TYPE_CONTENT)
                  GestureDetector(
                    onTap: () {
                      UserStore.of.checkLogin(() {
                        Get.bottomSheet(
                          isScrollControlled: true,
                          CommentPublishScreen(
                            relType: widget.viewParams.relType!,
                            relId: widget.viewParams.relId!,
                          ),
                        );
                      });
                    },
                    child: Container(
                      height: 32.w,
                      constraints: BoxConstraints(maxWidth: 101.w),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: '#333333'.hexColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '说点什么吧...',
                        style: TextStyle(fontSize: 12, color: '#333333'.hexColor.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _pushComment,
                    child: Container(
                      height: 32.w,
                      constraints: BoxConstraints(maxWidth: 101.w),
                      padding: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: '#333333'.hexColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: LoginHelper().getUserAvatar(widget.viewParams.author?.avatar ?? '', 30.w, 30.w),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                widget.viewParams.author?.nickname ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: '##333333'.hexColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if ((widget.viewParams.author?.id ?? 0) != 0)
                            Visibility(
                              visible: !UserStore.of.isMe(widget.viewParams.author?.id),
                              child: GestureDetector(
                                onTap: () {
                                  Get.find<FeedDetailController>(tag: Get.arguments.toString()).followToggle();
                                },
                                child: widget.viewParams.author?.followed == true
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                                        child: Text(
                                          '已关注',
                                          style: TextStyle(
                                            color: '#557BF6'.hexColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 28.w,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                                        child: Text(
                                          '+关注',
                                          style: TextStyle(
                                            color: '#557BF6'.hexColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                //  if (widget.viewParams.relType == 'thread')
                // CountCommentBadge(
                //   count: widget.viewParams.likeCount.abbreviateNumber,
                //   iconWidget: SizedBox(
                //     child: CountLikeAni(
                //       count: '',
                //       liked: widget.viewParams.liked == true,
                //       likeWidget: SizedBox(
                //         width: 20.w,
                //         child: widget.viewParams.liked == true
                //             ? SvgPicture.asset(Assets.svg.liked)
                //             : SvgPicture.asset(Assets.svg.like),
                //       ),
                //       onToggleLike: _likeToggle,
                //       usePlaceHolder: false,
                //     ),
                //   ),
                // ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _likeToggle,
                        child: CountCommentBadge(
                          count: widget.viewParams.likeCount.abbreviateNumber,
                          iconWidget: widget.viewParams.liked == true
                              ? SvgPicture.asset(
                                  Assets.svg.liked,
                                  width: 24.w,
                                  height: 24.w,
                                  color: '#567BF6'.hexColor.withOpacity(0.7),
                                )
                              : SvgPicture.asset(
                                  Assets.svg.like,
                                  color: '#333333'.hexColor.withOpacity(0.7),
                                  width: 24.w,
                                  height: 24.w,
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _favoriteToggle,
                        child: CountCommentBadge(
                          count: widget.viewParams.favoriteCount.abbreviateNumber,
                          iconWidget: widget.viewParams.favoriteState == true
                              ? SvgPicture.asset(
                                  Assets.svg.stared,
                                  color: '#567BF6'.hexColor.withOpacity(0.7),
                                  width: 24.w,
                                  height: 24.w,
                                )
                              : SvgPicture.asset(
                                  Assets.svg.star,
                                  color: '#333333'.hexColor.withOpacity(0.7),
                                  width: 24.w,
                                  height: 24.w,
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toCommentList,
                        child: CountCommentBadge(
                            iconWidget: SvgPicture.asset(
                              Assets.svg.comment,
                              color: '#333333'.hexColor,
                              width: 24.w,
                              height: 24.w,
                            ),
                            count: widget.viewParams.commentCount.abbreviateNumber),
                      ),
                      GestureDetector(
                        onTap: _toShare,
                        child: CountCommentBadge(
                            iconWidget: SvgPicture.asset(
                              Assets.svg.share,
                              color: '#333333'.hexColor,
                              width: 24.w,
                              height: 24.w,
                            ),
                            count: widget.viewParams.shareCount.abbreviateNumber),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 6.w,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _likeToggle() async {
    final data = await NetRequest().newContentLike({
      'relType': widget.viewParams.relType,
      'relId': widget.viewParams.relId,
      'state': widget.viewParams.liked ?? false ? false : true,
    });
    if (data is int) {
      EventBusUtil.of.fire(EventRefreshPage(widget.viewParams.relType ?? ''));
      widget.viewParams.likeCount = data;
      widget.viewParams.liked = !(widget.viewParams.liked ?? false);
      if (widget.viewParams.liked == true) {
        ToastUtils.showToast('点赞成功');
      } else {
        ToastUtils.showToast('取消点赞成功');
      }
      setState(() {});
      return true;
    }
    return false;
  }

  void _favoriteToggle() {
    NetRequest().favoriteToggle(
        widget.viewParams.relType, widget.viewParams.relId, !(widget.viewParams.favoriteState ?? false), (data) {
      if (widget.viewParams.favoriteState != true) {
        ToastUtils.showToast('收藏成功');
      } else {
        ToastUtils.showToast('取消收藏成功');
      }
      if (widget.viewParams.favoriteState == true) {
        widget.viewParams.favoriteState = false;
        widget.viewParams.favoriteCount = widget.viewParams.favoriteCount - 1;
      } else {
        widget.viewParams.favoriteState = true;
        widget.viewParams.favoriteCount = widget.viewParams.favoriteCount + 1;
      }
      setState(() {});
      EventBusUtil.of.fire(EventRefreshPage(widget.viewParams.relType ?? ''));
    });
  }

  void _toShare() {
    if (widget.viewParams.relType == 'thread') {
      NetRequest().threadUpCount(widget.viewParams.relId!, (data) async {
        await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${widget.viewParams.shareLink}'));
        ToastUtils.showToast('分享成功，链接已复制');
        widget.viewParams.shareCount = widget.viewParams.shareCount + 1;
        setState(() {});
      });
    } else {
      NetRequest().upCount(widget.viewParams.relId!, (data) async {
        await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${widget.viewParams.shareLink}'));
        ToastUtils.showToast('分享成功，链接已复制');
        widget.viewParams.shareCount = widget.viewParams.shareCount + 1;
        setState(() {});
      });
    }
  }

  void _pushComment() {
    UserStore.of.checkLogin(() {
      Get.toNamed(Routes.publishComment, arguments: {
        'relType': widget.viewParams.relType!,
        'relId': widget.viewParams.relId!,
      });
    });
  }

  void _toCommentList() {
    Get.toNamed(Routes.commentList, arguments: {
      'relId': widget.viewParams.relId!,
      'relType': widget.viewParams.relType!,
    });
  }
}

class TagListView extends StatelessWidget {
  const TagListView({
    super.key,
    required this.tagList,
  });

  final List<TagModel> tagList;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 12.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            tagList.length,
            (index) => GestureDetector(
              onTap: () {
                Get.toNamed(Routes.searchTag, arguments: {
                  'tag': tagList[index],
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: '#ECF0FE'.hexColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tagList[index].name ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: '#557BF6'.hexColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostBottomViewParams {
  int? postId; //帖子id
  int? relId; // 评论对象id
  String? relType; //  评论对象类型   // thread 帖子，content 内容，comment 评论
  bool? favoriteState; //收藏状态 true  false
  bool? liked; //点赞状态 true  false
  String? shareLink; //分享
  int likeCount;
  int favoriteCount;
  int commentCount;
  int shareCount;
  UserProfile? author;

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
    this.author,
  });
}
