import 'package:flutter/material.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../model/board_list.dart';
import '../../utils/app_theme.dart';
import '../../view/forum/CircleImageWithText.dart';
import '../../widget/label_view.dart';
import '../../widget/post_detail_bottom_view.dart';

class PostDetailPage extends StatefulWidget {
  int postId; //帖子id

  PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int currentPostId;
  // bool isFollowed = false;
  bool _isMounted = false;
  BoardBean? boardBean;

  List<String> items = [
    '评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容',
    '评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容'
  ];

  List<String> labelData = [
    '标签1',
    '标签2',
    '标签13',
    '标签14',
  ];

  @override
  void initState() {
    super.initState();
    currentPostId = widget.postId;
    _isMounted = true;
    NetRequest().threadShow(currentPostId.toString(), (data) {
      if (_isMounted) {
        setState(() {
          boardBean = BoardBean.fromJson(data);
        });

        print('object=========${boardBean!.user!.nickname!}');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
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
        bottomSheet:
            PostDetailBottomView(postId: currentPostId, relId: -1, relType: ''),
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
                              ? '发布于${boardBean!.createdAt}'
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
                Container(
                  child: Text(boardBean != null ? boardBean!.content! : '',
                      style: AppTheme.text666666Size16),
                ),
                SizedBox(
                  height: 15.px,
                ),
                GridView.builder(
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
                        onTap: () {},
                        child: Image.network(
                          _getImageUrl(boardBean!.files![index]),
                          width: 100,
                          height: 100,
                        ),
                      ); // 替换image_$index.jpg为对应的图片路径
                    }),
                SizedBox(height: 10),
                // Expanded(child: LabelView(isEditLabel: false, labelData: labelData, onItemTap: (value){}))
                // Visibility(
                //   child: Row(
                //     children: [
                //       Visibility(
                //         child: labelView(boardBean!.tags![0]),
                //       ),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       labelView(''),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       labelView(''),
                //     ],
                //   ),
                //   visible: boardBean!.tags!.isNotEmpty ? true : false,
                // )
              ],
            )),
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

  String _getImageUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
      return uploadFile.posterUrl!;
    } else {
      return uploadFile.url!;
    }
  }

  Widget commentsContent() {
    List<Widget> commentsList = [];
    for (int i = 0; i < items.length; i++) {
      commentsList.add(CommentItem());
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
        boardBean!.user!.id.toString(), !boardBean!.user!.followed!, (data) {
      if (_isMounted) {
        setState(() {});
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
    ;
  }
}
