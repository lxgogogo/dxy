import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/message.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageChildView extends StatefulWidget {
  final String type;

  const MessageChildView({super.key, required this.type});

  @override
  State<MessageChildView> createState() => MessageChildViewState();
}

class MessageChildViewState extends State<MessageChildView> {
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
      MessageList boardList = MessageList.fromJson(data);
      if (mounted) {
        final total = boardList.pager?.total ?? 0;
        if (pageNum == 1) {
          messages = boardList.list!;
          _refreshController.refreshCompleted();
          if (messages.length >= total) {
            _refreshController.loadNoData();
          } else {
            _refreshController.resetNoData();
          }
        } else {
          messages.addAll(boardList.list!);
          if (messages.length >= total) {
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

  void refreshData(String type) {
    strType = type;
    _onRefresh();
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.w),
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
              offset: Offset(0, 1.w),
              blurRadius: 2.rpx,
              spreadRadius: -1.w,
            ),
            BoxShadow(
              color: const Color(0xffffffff),
              offset: Offset(0, -1.w),
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
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              itemBuilder: (c, i) => messageCommentItem(messages[i], i),
              // itemExtent: 160.0,
              itemCount: messages.length, separatorBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.w),
                    color: const Color(0xffE7EDEE),
                  height: 1.w,
                );
      },
            ),
    );
  }

  jumpPage(MessageBean bean) {
    if (bean.jumpId == null) {
      return;
    }
    int id = bean.jumpId!;
    if (bean.resourceType == 'book') {
      Get.toNamed(Routes.bookDetail, arguments: id);
    } else if (bean.resourceType == 'article') {
      Get.toNamed(Routes.articleDetail, arguments: id);
    } else if (bean.resourceType == 'video' || bean.resourceType == 'videoList') {
      Get.toNamed(Routes.videoDetail, arguments: id);
    } else if (bean.resourceType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
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
    if (messageBean.resourceType == 'videoList') {
      return VideoCollectionItem(
        item: messageBean,
        onTap: () => jumpPage(messageBean),
      );
    }
    return Container(
      padding: EdgeInsets.only(top: 13.w, bottom: 20.w),
      margin: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.w), color: Colors.white),
            child: Stack(
              children: [
                Positioned(
                    left: 1.w,
                    top: 1.w,
                    child: ClipOval(
                        child: Image.network(
                      messageBean.fromUser?.avatar ?? '',
                      width: 32.w,
                      height: 32.w,
                      fit: BoxFit.cover,
                    ))),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      smallIcon,
                      width: 12.w,
                      height: 12.w,
                    ))
              ],
            ),
          ),
          SizedBox(
            width: 12.w,
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
                      messageBean.fromUser?.nickname ?? '',
                      style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.w, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    Text(DateFormat('MM-dd HH:mm').format(messageBean.createdAt!),
                        style: TextStyle(color: Color(0xff9CACC9), fontSize: 10.w)),
                  ],
                ),
                SizedBox(
                  height: 5.w,
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Color(0xff666666), fontSize: 11.w),
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    jumpPage(messageBean);
                  },
                  child: Container(
                      padding: EdgeInsets.only(bottom: 10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (str.isNotEmpty) Html(data: str) else SizedBox(height: 10.w),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: const Color(0x1A95A3C4), borderRadius: BorderRadius.all(Radius.circular(4.w))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (messageBean.contentUser?.nickname?.isNotEmpty == true)
                                  Text(messageBean.contentUser!.nickname!,
                                      style: TextStyle(
                                          color: Color(0xff2a2a2a),
                                          fontSize: 12.w,
                                          fontWeight: FontWeight.bold,
                                          height: 2.0)),
                                Text(messageBean.content?.title ?? '',
                                    style: TextStyle(color: Color(0xff2a2a2a), fontSize: 12.w, height: 2.0)),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 66.w,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/praise.png',
                                            width: 13.w,
                                            height: 13.w,
                                          ),
                                          SizedBox(
                                            width: 6.w,
                                          ),
                                          Text(
                                            '${messageBean.content?.likeCount ?? 0}',
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 66.w,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/star.png',
                                            width: 13.w,
                                            height: 13.w,
                                          ),
                                          SizedBox(
                                            width: 6.w,
                                          ),
                                          Text(
                                            '${messageBean.content?.favoriteCount ?? 0}',
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 66.w,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/comment.png',
                                            width: 13.w,
                                            height: 13.w,
                                          ),
                                          SizedBox(
                                            width: 6.w,
                                          ),
                                          Text(
                                            '${messageBean.content?.commentCount ?? 0}',
                                            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
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

class VideoCollectionItem extends StatelessWidget {
  final MessageBean? item;
  final VoidCallback? onTap;

  const VideoCollectionItem({
    super.key,
    this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                item?.content?.title ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 14.w,
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                item?.createdAt != null ? DateFormat('MM-dd HH:mm').format(item!.createdAt!) : '',
                style: TextStyle(
                  color: const Color(0xff9CACC9),
                  fontSize: 12.w,
                ),
              ),
            ],
          ),
          Text(
            '更新了新的视频',
            style: TextStyle(
              color: const Color(0xff9CACC9),
              fontSize: 12.w,
            ),
          ),
          SizedBox(height: 4.w),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0x1A95A3C4),
                borderRadius: BorderRadius.all(Radius.circular(4.w)),
              ),
              child: Row(
                children: [
                  if (item?.contentData?.cover?.isNotEmpty == true)
                    Container(
                      width: 48.w,
                      height: 48.w,
                      margin: EdgeInsets.only(right: 15.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.w)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: item!.contentData!.cover!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          'assets/images/image_loading_def.png',
                        ),
                      ),
                    ),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item?.contentData?.title ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: TextStyle(
                              color: const Color(0xff2a2a2a),
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 6.w),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/praise.png',
                                    width: 11.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    '${item?.content?.likeCount ?? 0}',
                                    style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
                                    maxLines: 1,
                                  )
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/star.png',
                                    width: 11.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    '${item?.content?.favoriteCount ?? 0}',
                                    style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
                                    maxLines: 1,
                                  )
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/comment.png',
                                    width: 11.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    '${item?.content?.commentCount ?? 0}',
                                    style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.w),
                                    maxLines: 1,
                                  )
                                ],
                              ),

                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
