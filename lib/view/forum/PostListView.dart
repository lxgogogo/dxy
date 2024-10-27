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

Widget PostListItemView(
    BuildContext context, int index, bool isForumList, BoardBean boardBean,
    {bool isShowMedia = true}) {

      getName(){
        return boardBean.user != null &&
                                boardBean.user!.nickname!.isNotEmpty
                            ? boardBean.user!.nickname!
                            : '德学院';
      }
  
  detailContent() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.only(right: 10.px),
              child: Row(
                children: [
                  Container(
                    child: ClipOval(
                      child: LoginHelper().getUserAvatar(
                          boardBean.user != null ? boardBean.user!.avatar! : '',
                          30,
                          30),
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
                        boardBean.title??'',
                        style: TextStyle(
                            color: const Color(0xff2a2a2a),
                            fontSize: 12.px,
                            height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (boardBean.createdAt != null)
                        Text(
                          getName()+' 发布于'+CommonUtils.timeFromNow(boardBean.createdAt!),
                          style: TextStyle(
                              color: const Color(0xff9CACC9), fontSize: 10.px),
                        )
                    ],
                  ))
                ],
              )),
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
            height: 5.px,
          ),
          Row(
            children: [
              SizedBox(
                width: 15.px,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/praise.png',
                    width: 11.px,
                    height: 12.px,
                  ),
                  SizedBox(
                    width: 4.px,
                  ),
                  Text(
                    '${boardBean.likeCount}',
                    style: TextStyle(
                        color: const Color(0xff9CACC9), fontSize: 10.px),
                    maxLines: 1,
                  )
                ],
              ),
              const Spacer(),
              Row(
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
              ),
              const Spacer(),
              Row(
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
              ),
              SizedBox(
                width: 15.px,
              ),
            ],
          ),
        ]);
  }

  return GestureDetector(
      onTap: () {
        if (boardBean.relType != null && boardBean.relType!.isNotEmpty) {
          if (boardBean.relType == 'content') {
            Get.to(ArticleDetailPage(id: boardBean.id! ?? 0));
          } else if (boardBean.relType == 'comment') {}
        } else {
          Get.to(PostDetailPage(postId: boardBean.id ?? 0));
        }
      },
      child: Stack(
        children: [
          LinearCard(
              padding: EdgeInsets.only(bottom: 2.px),
              margin: EdgeInsets.only(top: 10.px, left: 6.px, right: 6.px),
              child: Container(
                  padding: EdgeInsets.only(
                      left: 20.px, right: 12.px, top: 12.px, bottom: 12.px),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(13.px)),
                  ),
                  child: detailContent())),
          if (boardBean.sign != null && boardBean.sign!.isNotEmpty)
            Positioned(
                top: 0,
                right: 40,
                child: Container(
                  width: 38.px,
                  height: 21.px,
                  margin: EdgeInsets.only(top: 10.px),
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: boardBean.sign![0]=='newbie'?AssetImage('assets/images/post_newer.png'):AssetImage('assets/images/post_good.png'),
                          fit: BoxFit.fill)),
                  child: Text(
                    boardBean.sign![0]=='newbie'?'新人贴':boardBean.sign![0]=='boutique'?'精品贴':'官方贴',
                    style: TextStyle(color: Colors.white, fontSize: 10.px),
                  ),
                ))
        ],
      ));
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
        maxLines: 3,
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
    mainAxisAlignment: MainAxisAlignment.center, // 水平居中
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

  // return GridView.builder(
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           childAspectRatio:
  //               ((MediaQuery.of(context).size.width - 25) / imageCount) / 111,
  //           crossAxisCount: imageCount,
  //           crossAxisSpacing: 5.0,
  //           mainAxisSpacing: 5.0,
  //         ),
  //         itemCount: imageCount,
  //         // total number of images (you can change this according to your requirement)
  //         itemBuilder: (BuildContext context, int index) {
  //           return multipleImageView(
  //               (MediaQuery.of(context).size.width - 25) / imageCount,
  //               imgUrlList[index]);
  //         });
}

Widget singleImageView(String? imgUrl) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: MediaHelper().cacheLoadNetworkImage(
          imgUrl!.isNotEmpty ? imgUrl : '', 130.px, 90.px));
  // Image.network(
  //   imgUrl!,
  //   width: 130.px,
  //   height: 90.px,
  //   fit: BoxFit.cover,
  // ));
}

Widget multipleImageView(double imageWidth, String? imgUrl) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: MediaHelper().cacheLoadNetworkImage(
          imgUrl!.isNotEmpty ? imgUrl : '', imageWidth, 111.px));
  //         Image.network(
  //           imgUrl!,
  //           width: imageWidth,
  //           height: 111.px,
  //           fit: BoxFit.cover,
  //         ));
}

String getFilesUrl(UploadFile uploadFile) {
  if (uploadFile.type == 'video') {
    return uploadFile.posterUrl!;
  }
  return uploadFile.url!;
}
