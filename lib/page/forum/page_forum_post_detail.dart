import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_list.dart';
import '../../model/comment_list.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../view/forum/CircleImageWithText.dart';
import '../../widget/label_view.dart';
import '../../widget/post_detail_bottom_view.dart';
import 'media_helper.dart';

class PostDetailPage extends StatefulWidget {
  int postId; //帖子id

  PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int currentPostId;
  bool _isMounted = false;
  BoardBean? boardBean;
  var actionEventBus;
  List<String> imageUrlList = [];
  List<CommentBean> comments = [];

  late VideoPlayerController _playController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  late String videoUrl;
  late PostBottomViewParams postBottomViewParams;
  bool isLoadOk = false;

  @override
  void initState() {
    super.initState();
    currentPostId = widget.postId;
    _isMounted = true;
    reqPostDetail();
    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.refreshForumPostDetail.eventBusTypeName) {
        reqPostDetail();
      }
    });

    _playController = VideoPlayerController.network('');
    _initializeVideoPlayerFuture = _playController.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized
      setState(() {});
    });
  }

  reqPostDetail() {
    NetRequest().threadShow(currentPostId.toString(), (data) {
      if (_isMounted) {
        setState(() {
          boardBean = BoardBean.fromJson(data);
          //所有图片集合
          if (boardBean!.files!.isNotEmpty) {
            for (var element in boardBean!.files!) {
              if (boardBean!.files!.isNotEmpty &&
                  boardBean!.files!.length == 1) {
                if (element.type == 'video') {
                  videoUrl = element.url!;
                  imageUrlList.add(_getImageUrl(element));
                } else {
                  imageUrlList.add(_getImageUrl(element));
                }
              } else {
                imageUrlList.add(_getImageUrl(element));
              }
            }
          }

          postBottomViewParams =  PostBottomViewParams(
            postId: currentPostId,
            relId: currentPostId,
            relType: NetRequest.COMMENT_TYPE_THREAD,
            favoriteState: boardBean?.favorited!,
            title: boardBean?.title!,
            content: boardBean?.content!,
            files: boardBean?.files!,
          );

          isLoadOk = true;
        });
      }
    });

    NetRequest().commentList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {'relType': 'content', 'relId': currentPostId}
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

  Future<void> _pickAndPlayVideo(videoUrl) async {
    if (videoUrl != null) {
      _playController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _playController.initialize();
      _playController.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
    _playController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
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
          backgroundColor: Colors.white,
          title: const Text(''),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/more.png',
                  width: 22.px,
                  height: 22.px,
                ))
          ],
        ),
        body: SafeArea(child: contentView()),
        bottomSheet: isLoadOk ? PostDetailBottomView(
            viewParams: postBottomViewParams) : Container(),
        backgroundColor: Colors.white);
  }


  Widget contentView() {
    return ListView(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(16, 5, 16, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boardBean != null ? boardBean!.title! : '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text3B5078Size22,
                  softWrap: true,
                ),
                SizedBox(
                  height: 15.px,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleImageWithText(
                          imageUrl:
                              (boardBean != null && boardBean!.user != null)
                                  ? boardBean!.user!.avatar!
                                  : '',
                          imageWidth: 40,
                          imageHeight: 40,
                          topText: boardBean != null
                              ? boardBean!.user!.nickname!
                              : '',
                          topTextStyle: const TextStyle(),
                          bottomText1: boardBean != null
                              ? '发布于${DateFormat('MM-dd hh:mm').format(boardBean!.createdAt!)}'
                              : '',
                          bottomText1Style: AppTheme.text999999Size11,
                          bottomText2: '',
                          bottomText2Style: const TextStyle()),
                      (boardBean != null ? boardBean!.user!.followed! : false)
                          ? followedStatusBtn()
                          : IconButton(
                              onPressed: () {
                                _followToggle();
                              },
                              icon: Image.asset(
                                'assets/images/follow_btn.png',
                                width: 62,
                                height: 28,
                              ))
                    ]),
                SizedBox(height: 16),
                _showContentView(),
                SizedBox(
                  height: 15.px,
                ),
                _showMediaView(),
              ],
            )),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(16.px, 10.px, 16.px, 10.px),
            child: LabelView(
                isEditLabel: false,
                labelData: boardBean != null ? boardBean!.tags! : [],
                onItemTap: (value) {}),
          ),
        ),
        Container(height: 10.px, color: AppTheme.color_F3F3F3),
        Container(
            padding: EdgeInsets.fromLTRB(16, 15, 16, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '评论',
                style: AppTheme.text3B5078Size17,
              ),
              SizedBox(height: 19),
              commentsContent(),
              SizedBox(height: 100)
            ]))
      ],
    );
  }

  ///显示内容
  Widget _showContentView() {
    if (boardBean != null &&  boardBean!.content!.isNotEmpty) {
       if (boardBean!.content!.contains('<p>') || boardBean!.content!.contains('</p>')) {
         return Html(
         data:boardBean!.content!,
           extensions: [
             TagExtension(
               tagsToExtend: {"flutter"},
               child: const FlutterLogo(),
             ),
           ],
           style: {
             "p.fancy": Style(
               textAlign: TextAlign.center,
               backgroundColor: Colors.grey,
               margin: Margins(left: Margin(20, Unit.px), right: Margin.auto()),
               width: Width(300, Unit.px),
               fontWeight: FontWeight.bold,
             ),
           },
         );
       } else  {
         return Container(
           child: Text(boardBean != null ? boardBean!.content! : '',
               style: AppTheme.text666666Size16),
         );
       }
    }
    return  Container();
  }

  ///显示媒体文件 图片或者视频
  Widget _showMediaView() {
    if (boardBean != null &&
        boardBean!.files!.isNotEmpty &&
        boardBean!.files!.length == 1 &&
        boardBean!.files![0].type == 'video') {
      return Container(
          padding: EdgeInsets.fromLTRB(16.px, 16.px, 16.px, 0),
          height: 300.px,
          // width: calculateVideoPlayerWidth(context),
          child: Center(
            child: Stack(alignment: Alignment.center, children: [
              _playController.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.fitHeight,
                      child: SizedBox(
                        width: _playController.value.size.width,
                        height: _playController.value.size.height,
                        child: VideoPlayer(_playController),
                      ),
                    )
                  : Container(),
              _isPlaying
                  ? SizedBox.shrink()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          imageUrlList[0],
                        ),
                        IconButton(
                          icon: Image.asset('assets/images/play_btn.png',
                            width: 35.px,
                            height: 35.px,),
                          onPressed: () {
                            _pickAndPlayVideo(videoUrl);
                          },
                        ),
                      ],
                    )
            ]),
          ));
    } else {
      return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: boardBean != null ? boardBean!.files!.length : 0,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                MediaHelper().imagePerView(context, imageUrlList, index);
              },
              child: Image.network(
                imageUrlList[index],
                width: 100,
                height: 100,
              ),
            ); // 替换image_$index.jpg为对应的图片路径
          });
    }
    return Text('');
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
    NetRequest().followerToggle(
        boardBean!.user!.id!, !boardBean!.user!.followed!, (data) {
      if (_isMounted) {
        setState(() {
          reqPostDetail();
        });
      }
    });
  }

  Widget followedStatusBtn() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_0D000000,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
      child: Text('已关注', style: AppTheme.text999999Size13),
    );
  }
}
