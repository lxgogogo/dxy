import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/index/item_article.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_course.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/page/mine/dialog_confirm.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/board_list.dart';
import '../../model/collect_page_model.dart';
import '../../model/comment_list.dart';
import '../../model/user.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import '../../utils/storage.dart';
import '../../view/forum/PostListView.dart';
import '../../widget/no_data.dart';
import '../forum/page_forum_post_detail.dart';
import '../index/article_detail_page.dart';
import 'login_helper.dart';

class MineChildPage extends StatefulWidget {
  final int tabIndex;

  const MineChildPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MineChildPageState createState() => _MineChildPageState();
}

class _MineChildPageState extends State<MineChildPage> with TickerProviderStateMixin {
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

  reqListData() {
    if (widget.tabIndex == 0) {
      //帖子
      var ownerId = StorageUtil().prefs!.getString('ownerId');
      NetRequest().getThreadListByBoard(pageNum, pageSize, NetRequest.BOARD_SORT_TIME, '', ownerId!, '', (data) {
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
      NetRequest().userFavoriteList(pageNum, pageSize, '', (data) {
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
      NetRequest().userCommentList(pageNum, pageSize, '', (data) {
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
    reqListData();
  }

  void _onLoading() async {
    pageNum++;
    reqListData();
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    getUserInfo();
    reqListData();

    EventBusUtil.of.on<EventRefreshMyPageList>().listen((event) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
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
            header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
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
                                width: 22.px,
                                height: 22.px,
                              ),
                            ),
                          ],
                        ),
                        child: widget.tabIndex == 0
                            ? PostListItemView(boardPostList[i], isMyPost: true)
                            : widget.tabIndex == 1
                                ? _buildCollectItem(collectList[i])
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

  Widget _buildCollectItem(CollectModel collectModel) {
    if (collectModel.relType == 'thread') {
      if (collectModel.thread != null) {
        return PostListItemView(
          collectModel.thread!,
        );
      }
    } else if (collectModel.relType == 'content') {
      if (collectModel.content == null) return const SizedBox();
      if (['article', 'video', 'book', 'course'].contains(
        collectModel.content?.type,
      )) {
        return ArticleItem(
          article: collectModel.content!,
        );
      }
    }
    return const SizedBox();
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
    return Container(
      padding: EdgeInsets.fromLTRB(10.px, 10.px, 10.px, 12.px),
      margin: EdgeInsets.fromLTRB(10.px, 12.px, 10.px, 0),
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
                avatarSize: 42.px,
              ),
              SizedBox(
                width: 7.px,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileInfo?.nickname ?? '',
                      style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 14.px,
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
                          fontSize: 10.px,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.px,
          ),
          GestureDetector(
            onTap: () {
              if (item.resourceType == 'thread') {
                Get.to(PostDetailPage(postId: item.resourceId ?? 0));
              } else {
                Get.to(ArticleDetailPage(id: item.resourceId ?? 0));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.comment ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.px, color: const Color(0xff2a2a2a)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.px),
                  padding: EdgeInsets.all(8.px),
                  constraints: BoxConstraints(minHeight: 52.px),
                  decoration: const BoxDecoration(color: Color(0x1a95A3C4)),
                  child: Row(
                    children: [
                      if (item.files?.isNotEmpty == true)
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: item.files?.firstOrNull?.url ?? '',
                          width: 36.px,
                          height: 36.px,
                          placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                          errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                        ),
                      SizedBox(width: 10.px),
                      Expanded(
                        child: Text(
                          item.relType == 'thread'
                              ? item.thread?.title ?? ''
                              : item.relType == 'content'
                                  ? item.content?.title ?? ''
                                  : item.relType == 'comment'
                                      ? item.parentComment?.contentStr ?? ''
                                      : '',
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px),
                        ),
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
