import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';

import '../../model/board_list.dart';
import '../../page/forum/media_helper.dart';
import '../../page/forum/page_forum_post_detail.dart';
import '../../page/index/article_detail_page.dart';
import '../../utils/app_theme.dart';

Widget PostListItemView(BuildContext context, int index, bool isForumList, BoardBean boardBean,
    {bool isShowMedia = true}) {
  getName() {
    return boardBean.user != null && boardBean.user!.nickname!.isNotEmpty ? boardBean.user!.nickname! : '德学院';
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
    child: LinearCard(
      padding: EdgeInsets.only(bottom: 2.px),
      margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
      child: Padding(
        padding: EdgeInsets.all(12.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                BorderAvatar(avatar: boardBean.user?.avatar ?? ''),
                SizedBox(width: 8.px),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            boardBean.user?.nickname ?? '',
                            style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 12.px, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (boardBean.sign?.isNotEmpty == true) tagWidget(boardBean.sign!),
                        ],
                      ),
                      if (boardBean.createdAt != null)
                        Text(
                          CommonUtils.timeFromNow(boardBean.createdAt!),
                          style: TextStyle(
                            color: const Color(0xff9CACC9),
                            fontSize: 10.px,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 6.px),
            Text(
              boardBean.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff2c2c2c),
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
            SizedBox(height: 6.px),
            _showTextContentView(boardBean),
            Visibility(
                visible: boardBean.files != null && boardBean.files!.isEmpty ? false : true,
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.px,
                    ),
                    isShowMedia
                        ? mediaContent(context, index, boardBean.files != null ? boardBean.files! : [])
                        : Container(),
                  ],
                )),
            SizedBox(height: 6.px),
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
                      style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
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
                      style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
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
                      style: TextStyle(color: const Color(0xff9CACC9), fontSize: 10.px),
                      maxLines: 1,
                    )
                  ],
                ),
                SizedBox(
                  width: 15.px,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget tagWidget(List<String> sign) {
  var asset = 'assets/svg/post_office.svg';
  var text = '';
  if (sign.contains('office')) {
    asset = 'assets/svg/post_office.svg';
    text = '官方贴';
  } else if (sign.contains('boutique')) {
    asset = 'assets/svg/post_good.svg';
    text = '精品贴';
  } else if (sign.contains('newbie')) {
    asset = 'assets/svg/post_newer.svg';
    text = '新人贴';
  } else {
    return const SizedBox();
  }
  return Padding(
    padding: EdgeInsets.only(left: 8.px),
    child: Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(asset),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(2.px, 1.px, 2.px, 2.5.px),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.px,
            ),
          ),
        ),
      ],
    ),
  );
}

///显示内容
Widget _showTextContentView(BoardBean boardBean) {
  if (boardBean.content != null && boardBean.content!.isNotEmpty) {
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
  int picCount = files.length;
  if (picCount == 1 && files[0].type == 'image') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: getFilesUrl(files[0]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 179.px,
        placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
        errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
      ),
    );
  } else if (picCount == 1 && files[0].type == 'video') {
    //视频
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: getFilesUrl(files[0]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 179.px,
              placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
              errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
            ),
          ),
          Image.asset(
            'assets/images/play_btn.png',
            width: 32.px,
            height: 32.px,
          ),
        ],
      ),
    );
  } else if (picCount == 2) {
    return multipleImageWrap(context, 2, files.map((e) => getFilesUrl(e)).toList());
  } else if (picCount >= 3) {
    return multipleImageWrap(context, 3, files.map((e) => getFilesUrl(e)).toList());
  }
  return const SizedBox();
}

Widget multipleImageWrap(BuildContext context, int imageCount, List<String> imgUrlList) {
  return LayoutBuilder(builder: (context, constraints) {
    final itemWidth = (constraints.maxWidth - 2 * 6.px) / imageCount;
    return Wrap(
      spacing: 6.px,
      runSpacing: 6.px,
      children: List.generate(
        imgUrlList.length,
        (index) {
          String imageUrl = imgUrlList.length > index ? imgUrlList[index] : '';
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: itemWidth,
              height: itemWidth,
              placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
              errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
            ),
          );
        },
      ).toList(),
    );
  });
}

String getFilesUrl(UploadFile uploadFile) {
  if (uploadFile.type == 'video') {
    return uploadFile.posterUrl!;
  }
  return uploadFile.url!;
}
