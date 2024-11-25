import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:video_player/video_player.dart';

import '../../widget/background_container.dart';

class VideoDetailPage extends StatefulWidget {
  final int id;

  const VideoDetailPage({super.key, required this.id});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  ArticleDetailBean? articleDetailBean;
  late VideoPlayerController _playController;
  ChewieController? _chewieController;

  List<CommentBean> comments = [];
  bool loaded = false;
  bool showVideo = false;
  int pageNum = 1;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    requestDetail();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail();
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    _playController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  requestDetail() {
    NetRequest().contentShow({'id': widget.id}, (data) async {
      if (mounted) {
        if (data == null) {
          showToast('该视频已删除');
          Get.back();
          return;
        }
        articleDetailBean = ArticleDetailBean.fromJson(data);
        setState(() {});
        _playController = VideoPlayerController.networkUrl(
          Uri.parse(articleDetailBean?.video?.sourceUrl ?? ''),
        );
        await _playController.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _playController,
          autoPlay: true,
        );
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
        List<CommentBean> dataList =
            List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
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
          '详情',
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
                relType: NetRequest.COMMENT_TYPE_CONTENT,
                favoriteState: articleDetailBean?.favorited ?? false,
                title: '',
                liked: articleDetailBean?.liked ?? false,
                content: '',
                files: [],
                shareLink: 'details/video-${widget.id}',
                likeCount: articleDetailBean?.likeCount ?? 0,
                favoriteCount: articleDetailBean?.favoriteCount ?? 0,
                commentCount: articleDetailBean?.commentCount ?? 0,
                shareCount: articleDetailBean?.shareCount ?? 0,
              ),
            )
          : Container(),
    ));
  }

  detail() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.px, 8.px, 18.px, 124.px),
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
          GestureDetector(
            onTap: () {
              if (loaded) {
                if (_playController.value.isPlaying) {
                  _playController.pause();
                } else {
                  _playController.play();
                }
                showVideo = true;
                setState(() {});
              }
            },
            child: Container(
              height: 180.px,
              margin: EdgeInsets.symmetric(vertical: 16.px),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
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
                ],
              ),
              child: loaded && _chewieController != null
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: articleDetailBean?.cover ?? '',
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                        ),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
            ),
          ),
          Text(
            articleDetailBean?.description ?? '',
            style: TextStyle(
              color: const Color(0xff2a2a2a),
              fontSize: 16.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.px),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '评论(${articleDetailBean?.commentCount ?? 0})',
                style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10.px),
              if (loaded)
                if (comments.isNotEmpty)
                  ...List.generate(comments.length, (index) {
                    return CommentItem(
                      commentBean: comments[index],
                    );
                  })
                else
                  const Center(
                    child: NoDataView(),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
