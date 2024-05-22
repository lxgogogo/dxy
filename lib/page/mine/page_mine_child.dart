
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../model/thread_list.dart';
import '../../utils/net_request.dart';
import '../../utils/storage.dart';
import '../../view/forum/PostListView.dart';
import '../../widget/no_data.dart';

class MineChildPage extends StatefulWidget {
  int tabIndex;

  MineChildPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MineChildPageState createState() => _MineChildPageState();
}

class _MineChildPageState extends State<MineChildPage>
    with AutomaticKeepAliveClientMixin {
  int tabIndex = 0;
  int pageNum = 1;
  int pageSize = 10;

  var actionEventBus;
  bool _isMounted = false;

  List<BoardBean> boardPostList = [];
  List<BoardBean> commentDataList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);

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
    reqListData();
    print('==========================tabIndex:' + tabIndex.toString());
  }

  reqListData() {
    if (tabIndex == 0) {
      //帖子
      var ownerId = StorageUtil().prefs!.getString('ownerId');
      NetRequest().getThreadListByBoard(
          pageNum, pageSize, NetRequest.BOARD_SORT_TIME, '', ownerId!, '',
          (data) {
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
                      relType: element.relType!,
                      title: element.content!.title!,
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
                    content: element.content!.description!,
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
                  currentBoardList.add(element.thread != null ? element.thread! : BoardBean());
                } else if (element.relType == 'content') {
                  BoardBean boardBean = BoardBean(
                    id: element.content!.id!,
                    relType: element.relType!,
                    title: element.content!.title!,
                    content: element.content!.description!,
                    files: [UploadFile(url: element.content!.cover!)],
                    favoriteCount: element.content!.favoriteCount,
                    commentCount: element.content!.commentCount,
                    likeCount: element.content!.likeCount,
                  );
                  currentBoardList.add(boardBean);
                } else if (element.relType == 'comment') {

                }
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
    super.build(context);
    return Container(color: Colors.white,child:listView());
  }

  ///列表数据
  Widget listView() {
    if (loaded && (tabIndex == 2 ? commentDataList.length == 0 : boardPostList.length ==0)) {
      return Center(child: NoDataView(),);
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: tabIndex == 2 ? _refreshController2 : _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
        itemBuilder: (c, i) => PostListItemView(
          itemIndex: i,
          isForumList: false,
          boardBean:
              tabIndex == 2 ? commentDataList[i] : boardPostList[i],
        ),
        // itemExtent: 160.0,
        itemCount:
            tabIndex == 2 ? commentDataList.length : boardPostList.length,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
