import 'package:flutter/cupertino.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/board_list.dart';
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
  List<ThreadListBean> commentDataList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);

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
              currentBoardList.add(element.thread!);
            }
            if (pageNum == 1) {
              boardPostList = currentBoardList;
            } else {
              boardPostList.addAll(currentBoardList);
            }
          });
        }
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } else if (tabIndex == 2) {
      //评论
      NetRequest().userCommentList(pageNum, pageSize, '', (data) {
        ThreadList commentList = ThreadList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              commentDataList = commentList.list!;
            } else {
              commentDataList.addAll(commentList.list!);
            }
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
    if (tabIndex == 2) {
      return Expanded(
        child: commentDataList.isNotEmpty ? listView() : const NoDataView(),
      );
    } else {
      return Expanded(
          child: boardPostList.isNotEmpty ? listView() : const NoDataView());
    }
  }

  ///列表数据
  Widget listView() {
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
              tabIndex == 2 ? commentDataList[i].thread! : boardPostList[i],
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
