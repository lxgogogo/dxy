import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:video_player/video_player.dart';

import '../../view/background_container.dart';

// ignore: must_be_immutable
class VideoDetailPage extends StatefulWidget {
  int id;

  VideoDetailPage({super.key, required this.id});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  ArticleDetailBean? articleDetailBean;
  late VideoPlayerController _playController;
  late ChewieController _chewieController;

  List<CommentBean> comments = [];
  bool loaded = false;
  bool showVideo = false;
  var actionEventBus;
  int pageNum = 1;

  @override
  void initState() {
    super.initState();
    requestDetail();
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.refreshForumPostDetail.eventBusTypeName) {
        requestDetail();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _playController.dispose();
    _chewieController.dispose();
  }

  requestDetail() {
    NetRequest().articleDetail({'id': widget.id}, (data) async {
      if (mounted) {
        articleDetailBean = ArticleDetailBean.fromJson(data);
        setState(() {});
        _playController = VideoPlayerController.networkUrl(
          Uri.parse(articleDetailBean?.video?.sourceUrl ?? ''),
        );
        await _playController.initialize();
        _chewieController = ChewieController(
            videoPlayerController: _playController, autoPlay: false);
        loaded = true;
        setState(() {});
      }
    });

    NetRequest().commentList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {'relType': 'content', 'relId': widget.id}
    }, (data) {
      if (mounted) {
        List<CommentBean> dataList = List<CommentBean>.from(
            data['list'].map((comment) => CommentBean.fromJson(comment)));
        setState(() {
          comments = dataList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          '书籍详情',
          style: TextStyle(
            color: const Color(0xff2c2c2c),
            fontSize: 16.px,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: detail(),
      bottomSheet: articleDetailBean != null
          ? PostDetailBottomView(
              viewParams: PostBottomViewParams(
              postId: widget.id,
              relId: widget.id,
              relType: 'content',
              favoriteState: articleDetailBean?.favorited ?? false,
              title: '',
              content: '',
              shareLink: '/video_detail?id=${widget.id}',
              files: [],
            ))
          : Container(),
    ));
  }

  detail() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.px, 8.px, 18.px, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  articleDetailBean?.title ?? '',
                  style: TextStyle(
                    color: const Color(0xff2c2c2c),
                    fontSize: 20.px,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 15.px,
                ),
                Text(articleDetailBean?.description ?? '',
                    style: TextStyle(
                        color: Color(0xff3B5078),
                        fontSize: 16.px,
                        fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 15.px,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.px,
          ),
          GestureDetector(
              onTap: () {
                if (!loaded) return;
                _playController.value.isPlaying
                    ? _playController.pause()
                    : _playController.play();
                setState(() {
                  showVideo = true;
                });
              },
              child: Container(
                height: 210.px,
                child: loaded
                    ? Chewie(controller: _chewieController)
                    : const Center(child: CircularProgressIndicator()),
                // child: Stack(
                //   children: [
                //     _playController.value.isInitialized && showVideo
                //         ? VideoPlayer(_playController)
                //         : Image.network(
                //             articleDetailBean.cover ??
                //                 'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                //             width: 375.px,
                //             height: 210.px,
                //             fit: BoxFit.cover,
                //           ),
                //     Center(
                //       child: _playController.value.isPlaying
                //           ? Opacity(
                //               opacity: 0,
                //               child: Image.asset(
                //                 'assets/images/play.png',
                //                 width: 50.px,
                //                 height: 50.px,
                //               ),
                //             )
                //           : Image.asset(
                //               'assets/images/play.png',
                //               width: 50.px,
                //               height: 50.px,
                //             ),
                //     )
                //   ],
                // ),
              )),
          Container(
            padding: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '评论',
                  style: TextStyle(
                      color: Color(0xff3B5078),
                      fontSize: 17.px,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 18.px,
                ),
                if (comments.length == 0)
                  Center(
                    child: NoDataView(),
                  ),
                // CommentItem(),
                // CommentItem(),
                ...List.generate(comments.length, (index) {
                  return CommentItem(
                    commentBean: comments[index],
                  );
                }),
                SizedBox(
                  height: 100.px,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
