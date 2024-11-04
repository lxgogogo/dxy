import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/article_detail.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/view/forum/CircleImageWithText.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/post_detail_bottom_view.dart';
import 'package:intl/intl.dart';
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
                  height: 16.px,
                ),
                Row(children: [
                  Expanded(
                    child: CircleImageWithText(
                      imageUrl: articleDetailBean?.user?.avatar ?? '',
                      imageWidth: 38.px,
                      imageHeight: 38.px,
                      topText: articleDetailBean?.user?.nickname ?? '',
                      topTextStyle: TextStyle(
                        fontSize: 14.px,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2a2a2a),
                      ),
                      bottomText1: articleDetailBean?.createdAt != null
                          ? DateFormat('yyyy-MM-dd HH:mm')
                              .format(articleDetailBean!.createdAt!)
                          : '',
                      bottomText1Style: TextStyle(
                        fontSize: 12.px,
                        color: const Color(0xff999999),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: isOwnerPost() ? false : true,
                      child: articleDetailBean?.user?.followed == true
                          ? followedStatusBtn()
                          : IconButton(
                              onPressed: () {
                                _followToggle();
                              },
                              icon: Image.asset(
                                'assets/images/follow_btn.png',
                                width: 62,
                                height: 28,
                              )))
                ]),
                if (articleDetailBean?.description?.isNotEmpty == true) ...[
                  Text(articleDetailBean?.description ?? '',
                      style: TextStyle(
                          color: Color(0xff3B5078),
                          fontSize: 16.px,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: 15.px,
                  ),
                ],
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
                color: Colors.white,
                child: loaded
                    ? Chewie(controller: _chewieController)
                    : const Center(child: CircularProgressIndicator()),
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

  void _followToggle() {
    NetRequest().followerToggle(
        articleDetailBean!.user!.id!, !articleDetailBean!.user!.followed!,
        (data) {
      if (mounted) {
        requestDetail();
      }
    });
  }

  Widget followedStatusBtn() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_0D000000,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.px,
        vertical: 4.px,
      ),
      child: Text(
        '已关注',
        style: TextStyle(
          fontSize: 12.px,
          color: const Color(0xffd8d8d8),
        ),
      ),
    );
  }

  bool isOwnerPost() {
    if (articleDetailBean != null) {
      var ownerId = StorageUtil().prefs!.getString('ownerId');
      if (articleDetailBean?.user?.id?.toString() == ownerId) {
        return true;
      }
    }
    return false;
  }
}
