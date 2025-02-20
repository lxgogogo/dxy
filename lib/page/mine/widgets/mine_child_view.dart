import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/at_text.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/dialog_confirm.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/my_item_feed.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/board_list.dart';
import '../../../model/collect_page_model.dart';
import '../../../model/comment_list.dart';
import '../../../model/user.dart';
import '../../../utils/net_request.dart';
import '../../../widget/item_feed.dart';
import '../../../widget/no_data.dart';
import '../login_helper.dart';

class MineChildView extends StatefulWidget {
  final int tabIndex;

  const MineChildView({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MineChildViewState createState() => _MineChildViewState();
}

class _MineChildViewState extends State<MineChildView> with TickerProviderStateMixin {
  int pageNum = 1;
  int pageSize = 10;

  bool _isMounted = false;
  UserProfile? userProfileInfo;

  List<BoardBean> boardPostList = [];
  List<CollectModel> collectList = [];
  List<CommentBean> commentDataList = [];
  final ScrollController _listController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool loaded = false;

  getUserInfo() {
    LoginHelper().getUserInfo((data) {
      if (_isMounted) {
        userProfileInfo = data;
        setState(() {});
      }
    });
  }

  reqListData({bool showLoading = true}) {
    if (widget.tabIndex == 0) {
      Map<String, dynamic> params = {};
      params['pageNum'] = pageNum;
      params['pageSize'] = pageSize;
      params['ordered'] = NetRequest.BOARD_SORT_TIME;

      Map<String, dynamic> filters = {};
      var ownerId = UserStore.of.user.id;
      filters['ownerId'] = ownerId;
      params['filters'] = filters;
      NetRequest().getThreadListByBoard(params, showLoading: showLoading, (data) {
        BoardList boardList = BoardList.fromJson(data);
        if (_isMounted) {
          final total = boardList.pager?.total ?? 0;
          if (pageNum == 1) {
            boardPostList = boardList.list!;
            _refreshController.refreshCompleted();
            if (boardPostList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.resetNoData();
            }
          } else {
            boardPostList.addAll(boardList.list!);
            if (boardPostList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
          loaded = true;
          setState(() {});
        }
      });
    } else if (widget.tabIndex == 1) {
      //收藏
      NetRequest().userFavoriteList(pageNum, pageSize, '', showLoading:showLoading, (data) {
        CollectPageModel collectPageModel = CollectPageModel.fromJson(data);
        if (_isMounted) {
          final total = collectPageModel.pager?.total ?? 0;
          if (pageNum == 1) {
            collectList = collectPageModel.list!;
            _refreshController.refreshCompleted();
            if (collectList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.resetNoData();
            }
          } else {
            collectList.addAll(collectPageModel.list!);
            if (collectList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
          loaded = true;
          setState(() {});
        }
      });
    } else if (widget.tabIndex == 2) {
      //评论
      NetRequest().userCommentList(pageNum, pageSize, '', showLoading:showLoading, (data) {
        CommentList commentList = CommentList.fromJson(data);
        if (_isMounted) {
          final total = commentList.pager?.total ?? 0;
          if (pageNum == 1) {
            commentDataList = commentList.list!;
            _refreshController.refreshCompleted();
            if (commentDataList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.resetNoData();
            }
          } else {
            commentDataList.addAll(commentList.list!);
            if (commentDataList.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
          loaded = true;
          setState(() {});
        }
      });
    }
  }

  void _onRefresh() async {
    pageNum = 1;
    reqListData(showLoading: false);
  }

  void _onLoading() async {
    pageNum++;
    reqListData(showLoading: false);
  }

  StreamSubscription? eventSub1;
  StreamSubscription? eventSub2;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    getUserInfo();
    reqListData();

    eventSub1 = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      _onRefresh();
    });
    eventSub2 = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    eventSub1?.cancel();
    eventSub2?.cancel();
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return SlidableAutoCloseBehavior(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: loaded &&
                    (widget.tabIndex == 0
                        ? boardPostList.isEmpty
                        : widget.tabIndex == 1
                            ? collectList.isEmpty
                            : commentDataList.isEmpty)
                ? const NoDataView()
                : ListView.builder(
                    itemBuilder: (c, i) {
                      return Slidable(
                        groupTag: '${widget.tabIndex}-list',
                        key: ValueKey(
                          '${widget.tabIndex}-${widget.tabIndex == 0 ? boardPostList[i].id : widget.tabIndex == 1 ? collectList[i].id : commentDataList[i].id}',
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 42 / maxWidth,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final isConfirm = await showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) => DialogConfirm(
                                    title: widget.tabIndex == 0
                                        ? '确定要删除这个帖子吗？'
                                        : widget.tabIndex == 1
                                            ? '确定要删除这个收藏吗？'
                                            : '确定要删除这个评论吗？',
                                  ),
                                );
                                if (isConfirm == true) {
                                  if (widget.tabIndex == 0) {
                                    NetRequest().threadDelete(boardPostList[i].id, (data) {
                                      if (_isMounted) {
                                        ToastUtils.showToast('删除成功');
                                        reqListData();
                                      }
                                    });
                                  } else if (widget.tabIndex == 1) {
                                    NetRequest().favoriteDelete(collectList[i].id, (data) {
                                      if (_isMounted) {
                                        ToastUtils.showToast('删除成功');
                                        reqListData();
                                      }
                                    });
                                  } else if (widget.tabIndex == 2) {
                                    NetRequest().commentDelete(commentDataList[i].id, (data) {
                                      if (_isMounted) {
                                        ToastUtils.showToast('删除成功');
                                        reqListData();
                                      }
                                    });
                                  }
                                }
                              },
                              child: SvgPicture.asset(
                                'assets/svg/icon_delete.svg',
                                width: 22.w,
                                height: 22.w,
                              ),
                            ),
                          ],
                        ),
                        child: widget.tabIndex == 0
                            ? MyFeedItem(boardPostList[i])
                            : widget.tabIndex == 1
                                ? MyCollectItem(item: collectList[i])
                                : MyCommentItem(
                                    item: commentDataList[i],
                                    userProfileInfo: userProfileInfo,
                                  ),
                      );
                    },
                    itemCount: widget.tabIndex == 0
                        ? boardPostList.length
                        : widget.tabIndex == 1
                            ? collectList.length
                            : commentDataList.length,
                  ),
          ),
        );
      },
    );
  }
}

class MyCommentItem extends StatelessWidget {
  const MyCommentItem({
    super.key,
    required this.item,
    this.userProfileInfo,
  });

  final CommentBean item;
  final UserProfile? userProfileInfo;

  @override
  Widget build(BuildContext context) {
    //当前数据是内容的评论的回复 -> 内容的评论的回复
    //1.回复没删, 评论删了, 资源删了或者禁用 -> 回复保留, 评论显示 该评论已经删除, 不做资源跳转; -> 显示html其中的内容是 资源已被删除
    //2.回复没删, 评论删了, 资源没删 -> 回复保留, 评论显示 该评论已经删除,不做资源跳转; -> 显示?????
    //3.回复没删, 评论没删, 资源没删 -> 回复保留, 评论显示, 资源跳转;
    //4.回复没删 评论没删,资源删了或者禁用; -> 回复保留, 评论显示, 资源不跳转;  -> 显示html其中的内容是 资源已被删除;
    //
    //当前数据是内容的评论
    //5.评论没删, 资源删了或者禁用 -> 显示html其中的内容是 资源已被删除 ->  resourceId=17815(内容id或者帖子id) resourceType="video" delType=5
    //6.评论没删, 资源没删 -> 评论保留, 资源跳转;  ->  resourceId=17815(内容id或者帖子id) resourceType="video" delType=6
    String? cover;
    String? content;
    if (item.relType == 'thread') {
      cover = item.thread?.files?.firstOrNull?.url;
      content = item.thread?.title;
    } else if (item.relType == 'content') {
      cover = item.content?.cover;
      content = item.content?.title;
    } else if (item.relType == 'comment') {
      content = HtmlParseUtil.of.pureCommentText(item.parentComment?.contentStr);
    }

    String typeName = '';
    if (item.delType == 1 || item.delType == 2) {
      typeName = '评论';
    } else if (item.delType == 4) {
      typeName = '资源';
    } else {
      if (item.resourceType == 'thread') {
        typeName = '帖子';
      } else if (item.resourceType == 'article') {
        typeName = '资讯';
      } else if (item.resourceType == 'video') {
        typeName = '视频';
      } else if (item.resourceType == 'videoList') {
        typeName = '视频合集';
      } else if (item.resourceType == 'book') {
        typeName = '书籍';
      }
    }

    if (item.isDeleted) {
      content = '该$typeName已被删除';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 12.w),
      margin: EdgeInsets.fromLTRB(10.w, 12.w, 10.w, 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.rpx),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              BorderAvatar(
                avatar: userProfileInfo?.avatar ?? '',
                avatarSize: 36.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      userProfileInfo?.nickname ?? '',
                      style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.createdAt != null)
                      Text(
                        CommonUtils.timeFromNow(item.createdAt!),
                        style: TextStyle(
                          color: const Color(0xff9CACC9),
                          fontSize: 10.w,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10.w),
          GestureDetector(
            onTap: () {
              if (item.id == null) return;
              if (item.isDeleted) {
                ToastUtils.showToast('该$typeName已被删除');
                return;
              }
              final id = item.resourceId;
              if (id == null) return;
              if (item.resourceType == 'thread') {
                Get.toNamed(Routes.feedDetail, arguments: id);
              } else if (item.resourceType == 'article') {
                Get.toNamed(Routes.articleDetail, arguments: id);
              } else if (item.resourceType == 'book') {
                Get.toNamed(Routes.bookDetail, arguments: id);
              } else if (item.resourceType == 'video' || item.resourceType == 'videoList') {
                Get.toNamed(Routes.videoDetail, arguments: {'id': id});
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (HtmlParseUtil.of.pureCommentText(item.comment).isNotEmpty == true)
                  AtText(text: HtmlParseUtil.of.pureCommentText(item.comment)),
                Container(
                  margin: EdgeInsets.only(top: 10.w),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(minHeight: 48.w),
                  decoration: const BoxDecoration(color: Color(0x1a95A3C4)),
                  child: Row(
                    children: [
                      if (cover?.isNotEmpty == true)
                        Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: cover ?? '',
                                  width: 36.w,
                                  height: 36.w,
                                  placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                  errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                ),
                              ),
                              if (item.resourceType == 'videoList')
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '合集',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: item.isDeleted
                            ? Text(
                                content ?? '',
                                style: TextStyle(
                                  color: const Color(0xff2a2a2a),
                                  fontSize: 12.sp,
                                ),
                              )
                            : AtText(text: content ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCollectItem extends StatelessWidget {
  final CollectModel? item;

  const MyCollectItem({
    super.key,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    String? title;
    String? content;
    DateTime? createdAt;
    int? likeCount;
    int? commentCount;
    int? favoriteCount;
    String? imageUrl;
    if (item?.relType == 'thread') {
      title = item?.thread?.title;
      // content = item?.thread?.content;
      content = item?.thread?.pureText;
      createdAt = item?.thread?.createdAt;
      likeCount = item?.thread?.likeCount;
      commentCount = item?.thread?.commentCount;
      favoriteCount = item?.thread?.favoriteCount;
      imageUrl = item?.thread?.files?.firstOrNull?.url;
    } else if (item?.relType == 'content') {
      title = item?.content?.title;
      content = item?.content?.description;
      createdAt = item?.content?.createdAt;
      likeCount = item?.content?.likeCount;
      commentCount = item?.content?.commentCount;
      favoriteCount = item?.content?.favoriteCount;
      imageUrl = item?.content?.cover;
    }
    return GestureDetector(
      onTap: () {
        if (item?.id == null) return;
        if (item?.relType == 'thread') {
          final id = item?.thread?.id;
          if (id == null) return;
          Get.toNamed(Routes.feedDetail, arguments: id);
        } else if (item?.relType == 'content') {
          final type = item?.content?.type;
          final id = item?.content?.id;
          if (id == null) return;
          if (type == 'article') {
            Get.toNamed(Routes.articleDetail, arguments: id);
          } else if (type == 'book') {
            Get.toNamed(Routes.bookDetail, arguments: id);
          } else if (type == 'video' || type == 'videoList') {
            Get.toNamed(Routes.videoDetail, arguments: {'id': id});
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#F2F2F2'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title ?? '',
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.w),
            SizedBox(
              height: 66.w,
              child: Row(
                children: [
                  if (imageUrl?.isNotEmpty == true)
                    Container(
                      width: 88.w,
                      height: 66.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                            errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                          ),
                          if (item?.content?.type == 'videoList')
                            Positioned(
                              top: 2.w,
                              right: 2.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Text(
                                  '合集',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          content ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: '#333333'.hexColor,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            SimpleCountText(
                              count: likeCount?.abbreviateNumber ?? '0',
                              desc: '点赞',
                            ),
                            const SimpleDot(),
                            SimpleCountText(
                              count: commentCount?.abbreviateNumber ?? '0',
                              desc: '评论',
                            ),
                            const SimpleDot(),
                            SimpleCountText(
                              count: favoriteCount?.abbreviateNumber ?? '0',
                              desc: '收藏',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
