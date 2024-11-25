import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../utils/app_theme.dart';
import '../../utils/storage.dart';
import '../../view/forum/CircleImageWithText.dart';
import '../../widget/post_detail_bottom_view.dart';
import 'media_helper.dart';

class PostDetailPage extends StatefulWidget {
  final int id; //帖子id

  const PostDetailPage({super.key, required this.id});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int currentPostId;
  bool _isMounted = false;
  BoardBean? boardBean;
  List<String> imageUrlList = [];
  List<CommentBean> comments = [];

  VideoPlayerController? _playController;
  ChewieController? _chewieController;

  bool _isPlaying = false;
  String videoUrl = '';
  late PostBottomViewParams postBottomViewParams;
  bool isLoadOk = false;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    currentPostId = widget.id;
    _isMounted = true;
    reqPostDetail();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      reqPostDetail();
    });

    _playController = VideoPlayerController.network('');
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    _playController?.dispose();
    _chewieController?.dispose();
    super.dispose();
    _isMounted = false;
  }

  reqPostDetail() {
    NetRequest().threadShow(currentPostId.toString(), (data) async {
      if (_isMounted) {
        if (data == null) {
          showToast('该帖子已删除');
          Get.back();
          return;
        }
        boardBean = BoardBean.fromJson(data);
        //所有图片集合
        if (boardBean!.files!.isNotEmpty) {
          for (var element in boardBean!.files!) {
            if (boardBean!.files!.isNotEmpty && boardBean!.files!.length == 1) {
              if (element.type == 'video') {
                videoUrl = element.url ?? '';
                imageUrlList.add(_getImageUrl(element));
              } else {
                imageUrlList.add(_getImageUrl(element));
              }
            } else {
              imageUrlList.add(_getImageUrl(element));
            }
          }
        }

        postBottomViewParams = PostBottomViewParams(
          postId: currentPostId,
          relId: currentPostId,
          relType: NetRequest.COMMENT_TYPE_THREAD,
          favoriteState: boardBean?.favorited!,
          title: boardBean?.title!,
          liked: boardBean?.liked!,
          content: boardBean?.content!,
          files: boardBean?.files!,
          shareLink: 'details/thread-${widget.id}',
          likeCount: boardBean?.likeCount ?? 0,
          favoriteCount: boardBean?.favoriteCount ?? 0,
          commentCount: boardBean?.commentCount ?? 0,
          shareCount: boardBean?.shareCount ?? 0,
        );

        isLoadOk = true;
        setState(() {});
        if (videoUrl.isNotEmpty) {
          _playController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await _playController!.initialize();
          _chewieController = ChewieController(
            videoPlayerController: _playController!,
            autoPlay: true,
          );
          _isPlaying = true;
          setState(() {});
        }
      }
    });

    NetRequest().commentList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {'relType': 'Thread', 'relId': currentPostId}
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
      body: contentView(),
      bottomSheet: isLoadOk ? PostDetailBottomView(viewParams: postBottomViewParams) : Container(),
    ));
  }

  ///是自己的帖子 不显示关注
  bool isOwnerPost() {
    if (boardBean != null) {
      var ownerId = StorageUtil().prefs!.getString('ownerId');
      if (boardBean!.user?.id.toString() == ownerId) {
        return true;
      }
    }
    return false;
  }

  Widget contentView() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.px, 8.px, 18.px, 124.px),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            boardBean?.title ?? '',
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: 20.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.px),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CircleImageWithText(
                      imageUrl: (boardBean != null && boardBean!.user != null) ? boardBean!.user!.avatar! : '',
                      imageWidth: 40,
                      imageHeight: 40,
                      topText: boardBean != null ? boardBean!.user!.nickname! : '',
                      topTextStyle: const TextStyle(),
                      bottomText1: boardBean?.createdAt != null
                          ? '发布于${DateFormat('MM-dd HH:mm').format(boardBean!.createdAt!)}'
                          : '',
                      bottomText1Style: AppTheme.text999999Size11,
                      bottomText2: '',
                      bottomText2Style: const TextStyle()),
                ),
                if ((boardBean?.user?.id ?? 0) != 0)
                  Visibility(
                    visible: isOwnerPost() ? false : true,
                    child: GestureDetector(
                      onTap: _followToggle,
                      child: boardBean?.user?.followed == true
                          ? Container(
                              height: 28.px,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xffd8d8d8),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10.px),
                              child: const Text(
                                '已关注',
                                style: TextStyle(
                                  color: Color(0xff95a3c4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Container(
                              height: 28.px,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xff249cfc),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10.px),
                              child: const Text(
                                '+关注',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
          _showContentView(),
          _showMediaView(),
          // mediaContent(boardBean?.files  ?? []),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.px),
              Text(
                '评论(${comments.length})',
                style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10.px),
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

  ///显示内容
  Widget _showContentView() {
    if (boardBean?.content?.isNotEmpty == true) {
      if (boardBean!.content!.contains('<p>') || boardBean!.content!.contains('</p>')) {
        return Html(
          data: boardBean!.content!,
          onLinkTap: (url, attributes, element) {
            launchUrl(Uri.parse(url as String));
          },
        );
      } else {
        return Text(
          boardBean != null ? boardBean!.content! : '',
          style: TextStyle(
            color: const Color(0xff2A2A2A),
            fontSize: 14.px,
          ),
        );
      }
    }
    return const SizedBox();
  }

  ///显示媒体文件 图片或者视频
  Widget _showMediaView() {
    if (boardBean != null &&
        boardBean!.files!.isNotEmpty &&
        boardBean!.files!.length == 1 &&
        boardBean!.files![0].type == 'video') {
      return Container(
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
        child: _isPlaying && _chewieController != null
            ? Chewie(
                controller: _chewieController!,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: boardBean?.cover ?? '',
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                  ),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 16.px),
        itemCount: boardBean?.files?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              MediaHelper().imagePerView(
                context,
                boardBean!.files!.map((e) => e.url ?? '').toList(),
                index,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: boardBean?.files?[index].url ?? '',
                placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
              ),
            ),
          );
        },
      );
    }
  }

  String _getImageUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
      return uploadFile.posterUrl!;
    } else {
      return uploadFile.url!;
    }
  }

  Widget commentsContent() {
    List<Widget> commentsList = [];
    for (int i = 0; i < comments.length; i++) {
      commentsList.add(CommentItem(commentBean: comments[i]));
    }
    return Column(
      children: commentsList,
    );
  }

  Widget labelView(String labelValue) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_1A008EFF,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
      child: Text(
        labelValue,
        style: TextStyle(
          color: AppTheme.color_008EFF,
        ),
      ),
    );
  }

  void _followToggle() {
    Global().checkLogin(() {
      if (boardBean?.user?.id == null) return;
      final followed = boardBean?.user?.followed ?? false;
      NetRequest().followerToggle(boardBean!.user!.id!, !followed, (data) {
        if (_isMounted) {
          boardBean?.user?.followed = !followed;
          setState(() {});
        }
      });
    });
  }
}
