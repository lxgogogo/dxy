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
import 'package:holdem/page/mine/widgets/mine_collect_item.dart';
import 'package:holdem/page/mine/widgets/mine_comment_item.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/at_text.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/dialog_common.dart';
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
import '../../../widget/special_classic_footer.dart';
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
      NetRequest().userFavoriteList(pageNum, pageSize, '', showLoading: showLoading, (data) {
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
      NetRequest().userCommentList(pageNum, pageSize, '', showLoading: showLoading, (data) {
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
            footer: const SpecialClassicFooter(),
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
                                await showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) => CommonDialog(
                                    title: widget.tabIndex == 0
                                        ? '删除帖子'
                                        : widget.tabIndex == 1
                                            ? '删除收藏'
                                            : '删除评论',
                                    content:widget.tabIndex == 0
                                        ? '确定要删除这个帖子吗？'
                                        : widget.tabIndex == 1
                                        ? '确定要删除这个收藏吗？'
                                        : '确定要删除这个评论吗？',
                                    onConfirm: (){
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
                                    },
                                  ),
                                );
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
