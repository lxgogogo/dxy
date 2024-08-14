import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';

import '../../model/board_list.dart';
import '../../page/forum/media_helper.dart';
import '../../page/forum/page_forum_post_detail.dart';
import '../../page/index/page_article_detail.dart';
import '../../utils/app_theme.dart';

Widget MyPostListItemView(BuildContext context, int index, bool isForumList,
    BoardBean boardBean, int type,Function del,
    {bool isShowMedia = true}) {
  footer() {
    return Row(
      children: [
        if (boardBean.createdAt != null)
          Text(
            CommonUtils.timeFromNow(boardBean.createdAt!),
            style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
          ),
        const Spacer(),
        SizedBox(
          width: 55.px,
          child: Row(
            children: [
              Image.asset(
                'assets/images/heart.png',
                width: 11.px,
                height: 12.px,
              ),
              SizedBox(
                width: 4.px,
              ),
              Text(
                '${boardBean.likeCount}',
                style:
                    TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
                maxLines: 1,
              )
            ],
          ),
        ),

        SizedBox(
            width: 55.px,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/comment.png',
                  width: 11.px,
                  height: 12.px,
                ),
                SizedBox(
                  width: 4.px,
                ),
                Text(
                  '${boardBean.commentCount}',
                  style: TextStyle(
                      color: const Color(0xff9CACC9), fontSize: 10.px),
                  maxLines: 1,
                )
              ],
            )),
        SizedBox(
            width: 35.px,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/star.png',
                  width: 11.px,
                  height: 12.px,
                ),
                SizedBox(
                  width: 4.px,
                ),
                Text(
                  '${boardBean.favoriteCount}',
                  style: TextStyle(
                      color: const Color(0xff9CACC9), fontSize: 10.px),
                  maxLines: 1,
                )
              ],
            )),
        if (type == 1)
          GestureDetector(
            onTap: (){
              del(index);
            },
            child: Container(
              width: 30.px,
              height: 30.px,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/delete2.png',
                width: 6.px,
                height: 6.px,
              ),
            ),
          )
        // SizedBox(
        //   width: 15.px,
        // ),
      ],
    );
  }

  detailContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(right: 10.px),
          child: ClipOval(
            child: LoginHelper().getUserAvatar(
                boardBean.user != null ? boardBean.user!.avatar! : '', 30, 30),
          ),
        ),
        SizedBox(
          width: 5.px,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              boardBean.user != null && boardBean.user!.nickname!.isNotEmpty
                  ? boardBean.user!.nickname!
                  : '德学院',
              style: TextStyle(
                  color: const Color(0xff2a2a2a), fontSize: 12.px, height: 1.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 5.px,
            ),
            _showTextContentView(boardBean),
            Visibility(
                visible: boardBean.files != null && boardBean.files!.isEmpty
                    ? false
                    : true,
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.px,
                    ),
                    isShowMedia
                        ? mediaContent(context, index,
                            boardBean.files != null ? boardBean.files! : [])
                        : Container(),
                  ],
                )),
            SizedBox(
              height: 12.px,
            ),
            Container(width: 298.px, child: footer()),
            SizedBox(
              height: 12.px,
            )
          ],
        )),
      ],
    );
  }

  return GestureDetector(
      onTap: () {
        if (boardBean.relType != null && boardBean.relType!.isNotEmpty) {
          if (boardBean.relType == 'content') {
            Get.to(ArticleDetailPage(id: boardBean.id! ?? 0));
          } else if (boardBean.relType == 'comment') {}
        } else {
          Get.to(PostDetailPage(postId: boardBean.id! ?? 0));
        }
      },
      child: Container(
          padding: EdgeInsets.only(bottom: 2.px),
          margin: EdgeInsets.only(top: 10.px, left: 6.px, right: 6.px),
          decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: const Color(0xffe6e6e6), width: 1.px))),
          child: detailContent())

      // Container(
      //     padding: EdgeInsets.all(12.px),
      //     margin: EdgeInsets.only(top: 10.px, left: 0.px, right: 0.px),
      //     decoration: BoxDecoration(
      //       //flutter 上下颜色渐变
      //       //#F9CF3A, #FFD43E00
      //       gradient: LinearGradient(
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomCenter,
      //         colors: [
      //           isForumList
      //               ? Colors.white
      //               : Color(0xFF008EFF).withOpacity(0.03),
      //           isForumList
      //               ? Colors.white
      //               : Color(0xFF008EFF).withOpacity(0.03),
      //         ],
      //       ),
      //       boxShadow: const [
      //         BoxShadow(
      //           color: Colors.white,
      //           blurRadius: 4.0,
      //           spreadRadius: -4.0,
      //           offset: Offset(0.0, 6.0),
      //         ),
      //       ],
      //       borderRadius: BorderRadius.all(Radius.circular(13.px)),
      //     ),
      //     child: detailContent())

      );
}

///显示内容
Widget _showTextContentView(BoardBean boardBean) {
  if (boardBean != null &&
      boardBean.content != null &&
      boardBean.content!.isNotEmpty) {
    if (boardBean.content!.contains('<p>')) {
      return SizedBox(
        height: 90.px,
        child: Html(
          data: boardBean.content!,
          extensions: [
            TagExtension(
              tagsToExtend: {"flutter"},
              child: const FlutterLogo(
                textColor: AppTheme.color_008EFF,
                size: 14,
              ),
            ),
          ],
          style: {
            "p.fancy": Style(
              textAlign: TextAlign.center,
              backgroundColor: Colors.grey,
              margin: Margins(left: Margin(10, Unit.px), right: Margin.auto()),
              // width: Width(300, Unit.px),
              fontWeight: FontWeight.bold,
            ),
          },
        ),
      );
    } else {
      return Text(
        boardBean.content != null ? boardBean.content! : '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: const Color(0xff2a2a2a)),
        softWrap: true,
      );
    }
  } else {
    return Container();
  }
}

Widget mediaContent(BuildContext context, int index, List<UploadFile> files) {
  // print('files======length==${files.length}');
  int picCount = files.length;
  if (picCount == 1 && files[0].type == 'image') {
    return singleImageView(getFilesUrl(files[0]));
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
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/play_btn.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      )),
    );
  } else if (picCount == 0) {
    //不显示
    return Container();
  } else if (picCount == 2) {
    List<String> imageUrlList = [];
    imageUrlList.add(getFilesUrl(files[0]));
    imageUrlList.add(getFilesUrl(files[1]));
    return multipleImageWrap(context, 2, imageUrlList);
  } else if (picCount >= 3) {
    //大于等于3张
    List<String> imageUrlList = [];
    imageUrlList.add(getFilesUrl(files[0]));
    imageUrlList.add(getFilesUrl(files[1]));
    imageUrlList.add(getFilesUrl(files[2]));
    return multipleImageWrap(context, 3, imageUrlList);
  } else {
    return singleImageView(getFilesUrl(files[0]));
  }
}

Widget multipleImageWrap(
    BuildContext context, int imageCount, List<String> imgUrlList) {
  double widthNum = (MediaQuery.of(context).size.width - 70) / imageCount;
  return Row(
    // mainAxisAlignment: MainAxisAlignment.center, // 水平居中
    children: List.generate(
      imgUrlList.length, // 生成指定数量的图片Widget
      (index) {
        // 确保图片URL索引在列表范围内
        String imageUrl = imgUrlList.length > index ? imgUrlList[index] : '';
        return multipleImageView(widthNum, imageUrl);
      },
    ).map((image) {
      // 在每个图片Widget之间添加5个单位的间距
      return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: image,
      );
    }).toList(),
  );
}

Widget singleImageView(String? imgUrl) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: MediaHelper().cacheLoadNetworkImage(
          imgUrl!.isNotEmpty ? imgUrl : '', 82.px, 82.px));
}

Widget multipleImageView(double imageWidth, String? imgUrl) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: MediaHelper().cacheLoadNetworkImage(
          imgUrl!.isNotEmpty ? imgUrl : '', 82.px, 82.px));
}

String getFilesUrl(UploadFile uploadFile) {
  if (uploadFile.type == 'video') {
    return uploadFile.posterUrl!;
  }
  return uploadFile.url!;
}
