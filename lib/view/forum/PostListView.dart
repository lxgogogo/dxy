import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../model/board_list.dart';
import '../../page/forum/page_forum_post_detail.dart';
import '../../utils/app_theme.dart';

class PostListItemView extends StatefulWidget {
  int itemIndex;
  bool isForumList;
  BoardBean boardBean;

  PostListItemView({Key? key, required this.itemIndex, required this.isForumList, required this.boardBean}) : super(key: key);

  @override
  _PostDetailBottomViewState createState() => _PostDetailBottomViewState();
}

class _PostDetailBottomViewState extends State<PostListItemView> {
  bool isCollected = false;
  late int itemIndex;
  late bool isForumList;
  BoardBean boardBean = BoardBean();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemIndex = widget.itemIndex;
    isForumList = widget.isForumList;
    boardBean = widget.boardBean;
  }

  @override
  Widget build(BuildContext context) {
    return listDataItem(itemIndex);
  }

  Widget listDataItem(int index) {
    return GestureDetector(
        onTap: () {
          Get.to(PostDetailPage(postId: boardBean.id! ?? 0));
        },
        child: Container(
            padding: EdgeInsets.all(12.px),
            margin: EdgeInsets.only(top: 10.px, left: 0.px, right: 0.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isForumList ? Colors.white : Color(0xFFEEF7FE),
                  isForumList ? Colors.white : Color(0xFFEEF7FF),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 4.0,
                  spreadRadius: -4.0,
                  offset: Offset(0.0, 6.0),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(13.px)),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boardBean.title! ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text3B5078Size17,
                  ),
                  SizedBox(
                    height: 8.px,
                  ),
                  Row(
                    children: [
                      Container(
                        child: ClipOval(
                          child: LoginHelper().getUserAvatar(boardBean.user != null ? boardBean.user!.avatar! : ''
                              , 30, 30),
                        ),
                      ),
                      SizedBox(
                        width: 5.px,
                      ),
                      Text(
                        boardBean.user!=null ? boardBean.user.toString() : '',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.px,
                  ),
                   Text(
                    boardBean.content!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text666666Size14,
                    softWrap: true,
                  ),
                  Visibility(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.px,
                          ),
                          mediaContent(index, boardBean.files! ?? [])
                        ],
                      ),
                      visible: boardBean.files!.length == 0 ? false : true),
                  SizedBox(
                    height: 5.px,
                  ),
                  Text(
                    '${boardBean.likeCount}赞同 · ${boardBean.commentCount}评论 · ${boardBean.favoriteCount}收藏',
                    style: AppTheme.text999999Size12,
                    maxLines: 1,
                  )
                ])));
  }

  Widget mediaContent(int index, List<UploadFile> files) {
    int picCount = files.length;
    if (picCount == 1) {
      return singleImageView(
          getFilesUrl(files[0]));
    } else if (picCount == 1 && files[0].type == 'video') {
      //视频
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
        child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 335,
                  height: 188,
                  child: Image.network(
                    getFilesUrl(files[0]),
                    width: 335,
                    height: 188,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: AssetImage('assets/images/play_btn.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )),
      );
    } else if (picCount == 0) {//不显示
      return Image.network(
        'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
        width: 335,
        height: 188,
      );
    } else if (picCount == 2) {
      int num = 2;
      double screenWidth = MediaQuery.of(context).size.width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 10 -15) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,
        getFilesUrl(files[0])),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
    getFilesUrl(files[1])),
        ],
      );
    } else if (picCount >=3) {
      //大于等于3张
      int num = 3;
      double screenWidth = MediaQuery
          .of(context)
          .size
          .width;
      double imageWidth = (screenWidth - 5 * (num - 1) - 20 - 25) /
          num; // 计算每张图片的宽度 间距5 卡片左右间距10 内边距左右20
      return Row(
        children: [
          multipleImageView(imageWidth,
        getFilesUrl(files[0])),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
    getFilesUrl(files[1])),
          const SizedBox(
            width: 5,
          ),
          multipleImageView(imageWidth,
          getFilesUrl(files[2])),
        ],
      );
    } else {
      return singleImageView(
          getFilesUrl(files[0]));
    }
  }

  Widget singleImageView(String? imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl!,
          width: 130,
          height: 90,
          fit: BoxFit.fill,
        ));
  }

  Widget multipleImageView(double imageWidth, String? imgUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imgUrl!,
          width: imageWidth,
          height: 111,
          fit: BoxFit.cover,
        ));
  }

  String getFilesUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
       return uploadFile.posterUrl!;
    }
    return uploadFile.url!;
  }
}