import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/env.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';

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
  late PostBottomViewParams viewParams;

  @override
  void initState() {
    viewParams = widget.viewParams;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FeedDetailBottomView oldWidget) {
    if (oldWidget.viewParams != widget.viewParams) {
      viewParams = widget.viewParams;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          height: 68.w,
          padding: EdgeInsets.only(left: 25.w, top: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: _pushComment,
                  child: Container(
                    height: 30.w,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xff95A3C4).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 17.w),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/input_e.png',
                          width: 13.5.w,
                        ),
                        SizedBox(width: 9.5.w),
                        Expanded(
                          child: Text(
                            '说点什么',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xff9CACC9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (viewParams.relType == 'thread')
                InkWell(
                  onTap: _likeToggle,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Image.asset(
                          viewParams.liked == true ? 'assets/images/praised.png' : 'assets/images/praise.png',
                          width: 13.w,
                          height: 13.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${viewParams.likeCount}',
                          style: TextStyle(
                            color: const Color(0xff9cacc9),
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              InkWell(
                onTap: _favoriteToggle,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Image.asset(
                        viewParams.favoriteState == true ? 'assets/images/stared.png' : 'assets/images/star.png',
                        width: 13.w,
                        height: 13.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${viewParams.favoriteCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _toCommentList,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/comment.png',
                        width: 13.w,
                        height: 13.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${viewParams.commentCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _toShare,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/share.png',
                        width: 13.w,
                        height: 13.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${viewParams.shareCount}',
                        style: TextStyle(
                          color: const Color(0xff9cacc9),
                          fontSize: 12.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _likeToggle() {
    NetRequest().contentLike({
      'relType': viewParams.relType,
      'relId': viewParams.relId,
      'state': viewParams.liked ?? false ? false : true,
    }, (data) {
      if (viewParams.liked == true) {
        viewParams.liked = false;
        viewParams.likeCount = viewParams.likeCount - 1;
      } else {
        viewParams.liked = true;
        viewParams.likeCount = viewParams.likeCount + 1;
      }
      setState(() {});
      EventBusUtil.of.fire(EventRefreshPage(viewParams.relType ?? ''));
    });
  }

  void _favoriteToggle() {
    NetRequest().favoriteToggle(viewParams.relType, viewParams.relId, !(viewParams.favoriteState ?? false), (data) {
      ToastUtils.showToast(viewParams.favoriteState == true ? '取消成功' : '收藏成功');
      if (viewParams.favoriteState == true) {
        viewParams.favoriteState = false;
        viewParams.favoriteCount = viewParams.favoriteCount - 1;
      } else {
        viewParams.favoriteState = true;
        viewParams.favoriteCount = viewParams.favoriteCount + 1;
      }
      setState(() {});
      EventBusUtil.of.fire(EventRefreshPage(viewParams.relType ?? ''));
    });
  }

  void _toShare() {
    if (viewParams.relType == 'thread') {
      NetRequest().threadUpCount(viewParams.relId!, (data) async {
        await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${viewParams.shareLink}'));
        ToastUtils.showToast('分享成功，链接已复制');
        viewParams.shareCount = viewParams.shareCount + 1;
        setState(() {});
      });
    } else {
      NetRequest().upCount(viewParams.relId!, (data) async {
        await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${viewParams.shareLink}'));
        ToastUtils.showToast('分享成功，链接已复制');
        viewParams.shareCount = viewParams.shareCount + 1;
        setState(() {});
      });
    }
  }

  void _pushComment() {
    UserStore.of.checkLogin(() {
      Get.toNamed(Routes.publishComment, arguments: {
        'relType': viewParams.relType!,
        'relId': viewParams.relId!,
      });
    });
  }

  void _toCommentList() {
    Get.toNamed(Routes.commentList, arguments: {
      'relId': viewParams.relId!,
      'relType': viewParams.relType!,
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
      margin: EdgeInsets.only(top: 8.w, bottom: 12.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            tagList.length,
            (index) => GestureDetector(
              onTap: () {
                Get.toNamed(Routes.searchTag, arguments: {'tagId': tagList[index].id});
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.w),
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFEDF6FD),
                      Color(0xFFF2F9FF),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tagList[index].name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: '#249CFC'.hexColor,
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
  });
}
