import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
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

  PostListItemView(
      {Key? key,
      required this.itemIndex,
      required this.isForumList,
      required this.boardBean})
      : super(key: key);

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
                          child: LoginHelper().getUserAvatar(
                              boardBean.user != null
                                  ? boardBean.user!.avatar!
                                  : '',
                              30,
                              30),
                        ),
                      ),
                      SizedBox(
                        width: 5.px,
                      ),
                      Text(
                        boardBean.user != null ? boardBean.user!.nickname! : '',
                        style: AppTheme.text666666Size13,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.px,
                  ),
                  _showTextContentView(),
                  Visibility(
                      visible:
                          boardBean.files != null && boardBean.files!.isEmpty
                              ? false
                              : true,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.px,
                          ),
                          mediaContent(index,
                              boardBean.files != null ? boardBean.files! : []),
                        ],
                      )),
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

  ///显示内容
  Widget _showTextContentView() {
    if (boardBean.content!.isNotEmpty) {
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
                margin:
                    Margins(left: Margin(10, Unit.px), right: Margin.auto()),
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
          style: AppTheme.text666666Size14,
          softWrap: true,
        );
      }
    } else {
      return Container();
    }
  }

  Widget mediaContent(int index, List<UploadFile> files) {
    print('files======length==${files.length}');
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
      return multipleImageWrap(2, imageUrlList);
    } else if (picCount >= 3) {
      //大于等于3张
      List<String> imageUrlList = [];
      imageUrlList.add(getFilesUrl(files[0]));
      imageUrlList.add(getFilesUrl(files[1]));
      imageUrlList.add(getFilesUrl(files[2]));
      return multipleImageWrap(3, imageUrlList);
    } else {
      return singleImageView(getFilesUrl(files[0]));
    }
  }

  Widget multipleImageWrap(int imageCount, List<String> imgUrlList) {
    double widthNum = (MediaQuery.of(context).size.width - 60) / imageCount;
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
        child: Image.network(
          imgUrl!,
          width: 130.px,
          height: 90.px,
          fit: BoxFit.cover,
        ));
  }

  Widget multipleImageView(double imageWidth, String? imgUrl) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imgUrl!,
            width: imageWidth,
            height: 111.px,
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
