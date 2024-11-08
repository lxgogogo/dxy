import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/article_detail_page.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class MessageTabChildPage extends StatefulWidget {
  String type;

  MessageTabChildPage({super.key, required this.type});

  @override
  State<MessageTabChildPage> createState() => MessageTabChildPageState();
}

class MessageTabChildPageState extends State<MessageTabChildPage> {
  List<MessageBean> messages = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool loaded = false;
  int pageNum = 1;
  String strType = '';

  @override
  void initState() {
    super.initState();
    strType = widget.type;
    reqListData();
  }

  reqListData() {
    NetRequest().messageList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'type': strType}
    }, (data) {
      List<MessageBean> dataList = List<MessageBean>.from(data['list'].map((comment) => MessageBean.fromJson(comment)));

      if (mounted) {
        setState(() {
          if (pageNum == 1) {
            messages = dataList;
            loaded = true;
          } else {
            messages.addAll(dataList);
          }
        });
      }
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
    });
  }

  void refreshData(String type) {
    setState(() {
      strType = type;
      // pageId = id;
      // tabIdValue = id;
    });
    _onRefresh();
  }

  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      pageNum = 1;
    });
    reqListData();
  }

  void _onLoading() async {
    // monitor network fetch
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.px),
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height,
      ),
      decoration: BoxDecoration(
          color: const Color(0xfff8fbff),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffa2b9d0).withOpacity(0.64),
              offset: Offset(0, 1.px),
              blurRadius: 2.rpx,
              spreadRadius: -1.px,
            ),
            BoxShadow(
              color: const Color(0xffffffff),
              offset: Offset(0, -1.px),
              blurRadius: 2.rpx,
              spreadRadius: 0,
            ),
          ]),
      child: content(),
    );
  }

  Widget content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xff008EFF)),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: loaded && messages.isEmpty
          ? const Center(
              child: NoDataView(),
            )
          : ListView.builder(
              itemBuilder: (c, i) => messageCommentItem(messages[i], i),
              // itemExtent: 160.0,
              itemCount: messages.length,
            ),
    );
  }

  jumpPage(MessageBean bean) {
    if (bean.jumpId == null) {
      return;
    }
    int id = bean.jumpId!;
    if (bean.jumpType == 'book') {
      Navigator.of(context).pushNamed("/book_detail?id=${id}", arguments: id);
      // Get.to(BookDetailPage(id: id));
    } else if (bean.jumpType == 'article') {
      Navigator.of(context).pushNamed("/article_detail?id=${id}", arguments: id);
      // Get.to(ArticleDetailPage(id: id));
    } else if (bean.jumpType == 'videoList') {
      Navigator.of(context).pushNamed("/video_list?id=${id}", arguments: id);
      // Get.to(VideoListPage(id: id));
    } else if (bean.jumpType == 'video') {
      Navigator.of(context).pushNamed("/video_detail?id=${id}", arguments: id);
      // Get.to(VideoDetailPage(id: id));
    } else if (bean.jumpType == 'thread') {
      Get.to(PostDetailPage(postId: id));
    }
  }

  Widget messageCommentItem(MessageBean messageBean, int index) {
    String title = '@了我';
    String str = messageBean.description ?? '';
    String smallIcon = 'assets/images/aite.png';
    if (widget.type == 'comment') {
      title = '评论了我';
      smallIcon = 'assets/images/comment_small.png';
    } else if (widget.type == 'like') {
      title = '赞同了我';
      smallIcon = 'assets/images/zan.png';
    } else if (widget.type == 'favorite') {
      title = '收藏了我的帖子';
      smallIcon = 'assets/images/collect_small.png';
    }
    return Container(
      padding: EdgeInsets.only(top: 13.px, bottom: 20.px),
      margin: EdgeInsets.only(left: 16.px, right: 16.px),
      // decoration: BoxDecoration(
      //     border: Border(
      //         bottom: BorderSide(
      //             color: index == messages.length - 1
      //                 ? Colors.transparent
      //                 : const Color(0xffE5E5E5),
      //             width: 1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 34.px,
            height: 34.px,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.px), color: Colors.white),
            child: Stack(
              children: [
                Positioned(
                    left: 1.px,
                    top: 1.px,
                    child: ClipOval(
                        child: Image.network(
                      messageBean.fromUser!.avatar ?? '',
                      width: 32.px,
                      height: 32.px,
                      fit: BoxFit.cover,
                    ))),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      smallIcon,
                      width: 12.px,
                      height: 12.px,
                    ))
              ],
            ),
          ),
          SizedBox(
            width: 12.px,
          ),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageBean.fromUser!.nickname ?? '',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                      width: 6.px,
                    ),
                    Text(DateFormat('MM-dd HH:mm').format(messageBean.createdAt!),
                        style: TextStyle(color: Color(0xff9CACC9), fontSize: 10.px)),
                  ],
                ),
                SizedBox(
                  height: 5.px,
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Color(0xff666666), fontSize: 11.px),
                    ),
                    SizedBox(
                      width: 8.px,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.px,
                ),
                GestureDetector(
                  onTap: () {
                    jumpPage(messageBean);
                  },
                  child: Container(
                      padding: EdgeInsets.only(bottom: 10.px),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1.px, color: const Color(0xffE7EDEE)))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (str.isNotEmpty)
                            Text(
                              str,
                              style: TextStyle(color: Color(0xff333333), fontSize: 14.px),
                            ),
                          if (str.isNotEmpty)
                            SizedBox(
                              height: 8.px,
                            ),
                          Container(
                            padding: EdgeInsets.all(10.px),
                            width: 300.px,
                            decoration: BoxDecoration(
                                color: const Color(0x1A95A3C4), borderRadius: BorderRadius.all(Radius.circular(4.px))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (messageBean.contentUser != null && messageBean.contentUser!.nickname != null)
                                  Text(messageBean.contentUser!.nickname!,
                                      style: TextStyle(
                                          color: Color(0xff2a2a2a),
                                          fontSize: 12.px,
                                          fontWeight: FontWeight.bold,
                                          height: 2.0)),
                                Text(messageBean.content!.title ?? '',
                                    style: TextStyle(color: Color(0xff2a2a2a), fontSize: 12.px, height: 2.0)),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 66.px,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/praise.png',
                                            width: 13.px,
                                            height: 13.px,
                                          ),
                                          SizedBox(
                                            width: 6.px,
                                          ),
                                          Text(
                                            messageBean.content!.likeCount.toString(),
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 66.px,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/star.png',
                                            width: 13.px,
                                            height: 13.px,
                                          ),
                                          SizedBox(
                                            width: 6.px,
                                          ),
                                          Text(
                                            messageBean.content!.favoriteCount.toString(),
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 66.px,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/comment.png',
                                            width: 13.px,
                                            height: 13.px,
                                          ),
                                          SizedBox(
                                            width: 6.px,
                                          ),
                                          Text(
                                            messageBean.content!.commentCount.toString(),
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ]))
        ],
      ),
    );
  }
}
