import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/page_article_detail.dart';
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
  State<MessageTabChildPage> createState() => _MessageTabChildPageState();
}

class _MessageTabChildPageState extends State<MessageTabChildPage> {
  List<MessageBean> messages = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool loaded = false;
  int pageNum = 1;

  @override
  void initState() {
    super.initState();
    reqListData();
  }

  reqListData() {
    NetRequest().messageList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'type': widget.type}
    }, (data) {
      List<MessageBean> dataList = List<MessageBean>.from(
          data['list'].map((comment) => MessageBean.fromJson(comment)));

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
    SizeFit.initialize(context);
    if (loaded && messages.length == 0) {
      return const Center(
        child: NoDataView(),
      );
    }
    return content();
  }

  Widget content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => messageCommentItem(messages[i],i),
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
      Get.to(BookDetailPage(id: id));
    } else if (bean.jumpType == 'article') {
      Get.to(ArticleDetailPage(id: id));
    } else if (bean.jumpType == 'videoList') {
      Get.to(VideoListPage(id: id));
    } else if (bean.jumpType == 'video') {
      Get.to(VideoDetailPage(id: id));
    } else if (bean.jumpType == 'thread') {
      Get.to(PostDetailPage(postId: id));
    }
  }

  Widget messageCommentItem(MessageBean messageBean,int index) {
    String title = '@了我';
    String str = messageBean.description ?? '';
    if (widget.type == 'comment') {
      title = '评论了我';
    } else if (widget.type == 'like') {
      title = '赞同了我';
    } else if (widget.type == 'favorite') {
      title = '收藏了我的帖子';
    }
    return Container(
      padding: EdgeInsets.only(top: 13.px, bottom: 20.px),
      margin: EdgeInsets.only(left: 16.px, right: 16.px),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: index==messages.length-1?Colors.transparent:const Color(0xffE5E5E5), width: 1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.px,
            height: 40.px,
            child: ClipOval(
              child: Image.network(
                messageBean.fromUser!.avatar ?? '',
                width: 40.px,
                height: 40.px,
                fit: BoxFit.cover,
              ),
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
                Text(
                  messageBean.fromUser!.nickname ?? '',
                  style: TextStyle(
                      color: const Color(0xff3B5078),
                      fontSize: 13.px,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5.px,
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(color: Color(0xff666666), fontSize: 11.px),
                    ),
                    SizedBox(
                      width: 8.px,
                    ),
                    Text(
                        DateFormat('MM-dd HH:mm')
                            .format(messageBean.createdAt!),
                        style: TextStyle(
                            color: Color(0xff999999), fontSize: 11.px))
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
                      padding: EdgeInsets.only(left: 9.px),
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  width: 3.px,
                                  color: Colors.black.withOpacity(0.05)))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (str.isNotEmpty)
                            Text(
                              str,
                              style: TextStyle(
                                  color: Color(0xff333333), fontSize: 14.px),
                            ),
                          if (str.isNotEmpty)
                            SizedBox(
                              height: 8.px,
                            ),
                          Container(
                            padding: EdgeInsets.all(10.px),
                            width: 300.px,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.px))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(messageBean.quote ?? '',
                                    style: TextStyle(
                                        color: Color(0xff666666),
                                        fontSize: 14.px,
                                        height: 2.0))
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
