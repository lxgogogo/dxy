import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/MyPostListView.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../model/thread_list.dart';
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
  int tabIndex;

  MineChildPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MineChildPageState createState() => _MineChildPageState();
}

class _MineChildPageState extends State<MineChildPage> {
  int tabIndex = 0;
  int pageNum = 1;
  int pageSize = 10;

  var actionEventBus;
  bool _isMounted = false;
  UserProfile userProfileInfo = UserProfile(); //

  List<BoardBean> boardPostList = [];
  List<BoardBean> commentDataList = [];
  final ScrollController _listController = ScrollController();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  RefreshController _refreshController2 = RefreshController(initialRefresh: false);

  bool loaded = false;

  void _onRefresh() async {
    setState(() {
      pageNum = 1;
    });
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    tabIndex = widget.tabIndex;
    getUserInfo();
    reqListData();
    print('==========================tabIndex:' + tabIndex.toString());

    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshMineFavoriteList.eventBusTypeName) {
        if (_isMounted) {
          if (tabIndex == 1) {
            //刷新收藏列表
            pageNum = 1;
            setState(() {
              reqListData();
              _scrollToTop();
            });
          }
        }
      }
    });
  }

  getUserInfo() {
    LoginHelper().getUserInfo((data) {
      if (_isMounted) {
        setState(() {
          userProfileInfo = data;
          print('userProfile=======${userProfileInfo.nickname!}');
        });
      }
    });
  }

  reqListData() {
    if (tabIndex == 0) {
      //帖子
      var ownerId = StorageUtil().prefs!.getString('ownerId');
      NetRequest().getThreadListByBoard(pageNum, pageSize, NetRequest.BOARD_SORT_TIME, '', ownerId!, '', (data) {
        BoardList boardList = BoardList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              boardPostList = boardList.list!;
            } else {
              boardPostList.addAll(boardList.list!);
            }
            loaded = true;
          });
        }
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } else if (tabIndex == 1) {
      //收藏
      NetRequest().userFavoriteList(pageNum, pageSize, '', (data) {
        ThreadList followedFansList = ThreadList.fromJson(data);
        if (_isMounted) {
          setState(() {
            List<BoardBean> currentBoardList = [];
            for (var element in followedFansList.list!) {
              if (element.relType != null) {
                if (element.relType == 'thread') {
                  currentBoardList.add(element.thread != null ? element.thread! : BoardBean());
                } else if (element.relType == 'content') {
                  BoardBean boardBean = BoardBean(
                    id: element.content!.id!,
                    orignalId: element.id!,
                    relType: element.relType!,
                    title: element.content!.title!,
                    user: UserProfile(nickname: element.content!.author!, avatar: ''),
                    content: element.content!.description!,
                    files: [UploadFile(url: element.content!.cover!)],
                    favoriteCount: element.content!.favoriteCount,
                    commentCount: element.content!.commentCount,
                    likeCount: element.content!.likeCount,
                  );
                  currentBoardList.add(boardBean);
                } else if (element.relType == 'comment') {
                  BoardBean boardBean = BoardBean(
                    title: element.content!.title!,
                    orignalId: element.id!,
                    content: element.content!.description!,
                    // contentBean: element.content!,
                    files: [UploadFile(url: element.content!.cover!)],
                    favoriteCount: element.content!.favoriteCount,
                    commentCount: element.content!.commentCount,
                    likeCount: element.content!.likeCount,
                  );
                  currentBoardList.add(element.comment != null ? element.comment! : BoardBean());
                }
              }
            }
            if (pageNum == 1) {
              boardPostList = currentBoardList;
            } else {
              boardPostList.addAll(currentBoardList);
            }
            loaded = true;
          });
        }
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } else if (tabIndex == 2) {
      //评论
      NetRequest().userCommentList(pageNum, pageSize, '', (data) {
        CommentList commentList = CommentList.fromJson(data);
        if (_isMounted) {
          setState(() {
            List<BoardBean> currentBoardList = [];
            for (var element in commentList.list!) {
              if (element.relType != null) {
                if (element.relType == 'thread') {
                  BoardBean boardBean = BoardBean();
                  boardBean = element.thread != null ? element.thread! : BoardBean();
                  boardBean.comment = element.comment;
                  boardBean.createdAt = element.createdAt;
                  currentBoardList.add(boardBean);
                } else if (element.relType == 'content') {
                  BoardBean boardBean = BoardBean(
                    id: element.content!.id!,
                    user: UserProfile(nickname: element.content!.author!, avatar: ''),
                    relType: element.relType!,
                    title: element.content!.title!,
                    content: element.content!.description!,
                    cover: element.content!.cover,
                    files: [UploadFile(url: element.content!.cover!)],
                    favoriteCount: element.content!.favoriteCount,
                    commentCount: element.content!.commentCount,
                    likeCount: element.content!.likeCount,
                    createdAt: element.createdAt!,
                    comment: element.comment!,
                  );
                  currentBoardList.add(boardBean);
                } else if (element.relType == 'comment') {}
              }
            }
            if (pageNum == 1) {
              commentDataList = currentBoardList;
            } else {
              commentDataList.addAll(currentBoardList);
            }
            loaded = true;
          });
        }
      });
      _refreshController2.refreshCompleted();
      _refreshController2.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Container(color: Colors.transparent, child: listView());
  }

  ///列表数据
  Widget listView() {
    if (loaded && (tabIndex == 2 ? commentDataList.length == 0 : boardPostList.length == 0)) {
      return const Center(
        child: NoDataView(),
      );
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: tabIndex == 2 ? _refreshController2 : _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => tabIndex == 2
            ? commentItem(commentDataList[i], i)
            : PostListItemView(
                context,
                i,
                false,
                boardPostList[i],
                isMyPost:true,
              ),
        itemCount: tabIndex == 2 ? commentDataList.length : boardPostList.length,
      ),
    );
  }

  // @override
  // // TODO: implement wantKeepAlive
  // bool get wantKeepAlive => true;

  @override
  void dispose() {
    _isMounted = false;
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  void _scrollToTop() {
    // 滚动到顶部的逻辑
    _listController.animateTo(
      0.0, // 滚动到顶部的偏移量
      duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
      curve: Curves.ease, // 滚动动画的曲线
    );
  }

  Widget commentItem(BoardBean boardBean, int index) {
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
              Container(
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: CircleBorder(),
                ),
                child: ClipOval(
                    child: LoginHelper().getUserAvatar(
                  userProfileInfo.avatar ?? '',
                  42.px,
                  42.px,
                )),
              ),
              SizedBox(
                width: 7.px,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileInfo.nickname ?? '',
                      style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 14.px,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (boardBean.createdAt != null)
                      Text(
                        CommonUtils.timeFromNow(boardBean.createdAt!),
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
                if (boardBean.relType != null && boardBean.relType!.isNotEmpty) {
                  if (boardBean.relType == 'content') {
                    Get.to(ArticleDetailPage(id: boardBean.id ?? 0));
                  } else if (boardBean.relType == 'comment') {}
                } else {
                  Get.to(PostDetailPage(postId: boardBean.id ?? 0));
                }
              },
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    boardBean.comment ?? '',
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
                        if (boardBean.cover != null)
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: boardBean.cover ?? '',
                            width: 36.px,
                            height: 36.px,
                            placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                            errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                          ),
                        SizedBox(
                          width: 10.px,
                        ),
                        Expanded(
                            child: Text(
                          boardBean.title ?? '',
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xff2a2a2a), fontSize: 12.px),
                        )),
                      ],
                    ),
                  ),
                  // Container(
                  //   // padding: EdgeInsets.all(10.px),
                  //   width: 300.px,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       PostListItemView(context, index, false, boardBean,
                  //           isShowMedia: false)
                  //     ],
                  //   ),
                  // )
                ],
              )))
        ],
      ),
      // child: Row(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [

      //           SizedBox(
      //             height: 10.px,
      //           ),
      // ,
      //           )
      //         ]))
      //   ],
      // ),
    );
  }
}
