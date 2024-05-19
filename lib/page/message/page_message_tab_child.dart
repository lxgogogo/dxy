import 'package:flutter/material.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/page/comment/item_comment.dart';
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
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  List<MessageBean> messages = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    NetRequest().messageList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {'type': widget.type}
    }, (data) {
      List<MessageBean> dataList = List<MessageBean>.from(
          data['list'].map((comment) => MessageBean.fromJson(comment)));
      if (mounted) {
        setState(() {
          messages = dataList;
          loaded = true;
        });
      }
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    if (loaded && messages.length == 0) {
      return const Center(
        child:  NoDataView(),
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
        itemBuilder: (c, i) => messageCommentItem(messages[i]),
        // itemExtent: 160.0,
        itemCount: messages.length,
      ),
    );
  }

  Widget messageCommentItem(MessageBean messageBean) {
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
              bottom: BorderSide(color: Color(0xffE5E5E5), width: 1.px))),
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
                        DateFormat('MM-dd hh:mm')
                            .format(messageBean.createdAt!),
                        style: TextStyle(
                            color: Color(0xff999999), fontSize: 11.px))
                  ],
                ),
                SizedBox(
                  height: 10.px,
                ),
                Container(
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
              ]))
        ],
      ),
    );
  }

  Widget videoDataItem(int index) {
    return Container(
      padding: EdgeInsets.only(top: 13.px, bottom: 20.px),
      margin: EdgeInsets.only(left: 16.px, right: 16.px),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffE5E5E5), width: 1.px))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
              width: 40.px,
              height: 40.px,
              fit: BoxFit.cover,
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
                  'data',
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
                      '@我的',
                      style:
                          TextStyle(color: Color(0xff666666), fontSize: 11.px),
                    ),
                    SizedBox(
                      width: 8.px,
                    ),
                    Text('2024-1-1',
                        style: TextStyle(
                            color: Color(0xff999999), fontSize: 11.px))
                  ],
                ),
                SizedBox(
                  height: 10.px,
                ),
                Container(
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
                        Text(
                          '@Ray 来看这篇文章',
                          style: TextStyle(
                              color: Color(0xff333333), fontSize: 14.px),
                        ),
                        SizedBox(
                          height: 8.px,
                        ),
                        Container(
                          padding: EdgeInsets.all(10.px),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.px))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('用户2：说的好回复评论说的好回复评论说的好回复评论',
                                  style: TextStyle(
                                      color: Color(0xff666666),
                                      fontSize: 14.px,
                                      height: 2.0))
                            ],
                          ),
                        )
                      ],
                    )),
              ]))
        ],
      ),
    );
  }
}
