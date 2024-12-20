import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';

import '../model/board_list.dart';
import '../utils/app_theme.dart';

Widget FeedItem(BoardBean item, {bool isMyPost = false}) {
  Widget child = Padding(
    padding: EdgeInsets.all(12.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            BorderAvatar(avatar: item.user?.avatar ?? ''),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.user?.nickname ?? '',
                        style: TextStyle(
                          color: const Color(0xff2a2a2a),
                          fontSize: 12.sp,
                        ),
                      ),
                      if (item.sign?.isNotEmpty == true) tagWidget(item.sign!),
                    ],
                  ),
                  if (item.createdAt != null)
                    Text(
                      CommonUtils.timeFromNow(item.createdAt!),
                      style: TextStyle(
                        color: const Color(0xff9cacc9),
                        fontSize: 10.sp,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 8.w),
        Text(
          item.title ?? '',
          style: TextStyle(
            color: const Color(0xff2a2a2a),
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.content?.isNotEmpty == true)
          Text(
            item.pureText ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xff2a2a2a),
            ),
            softWrap: true,
          ),
        Visibility(
          visible: item.files != null && item.files!.isEmpty ? false : true,
          child: Padding(
            padding: EdgeInsets.only(top: 8.w),
            child: mediaContent(
              item.files != null ? item.files! : [],
            ),
          ),
        ),
        SizedBox(height: 8.w),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/praise.png',
                    width: 13.w,
                    height: 13.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${item.likeCount ?? 0}',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/comment.png',
                    width: 13.w,
                    height: 13.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${item.commentCount ?? 0}',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/star.png',
                    width: 13.w,
                    height: 13.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${item.favoriteCount ?? 0}',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return GestureDetector(
    onTap: () {
      if (item.relType != null && item.relType!.isNotEmpty) {
        if (item.relType == 'content') {
          Get.toNamed(Routes.articleDetail, arguments: item.id ?? 0);
        } else if (item.relType == 'comment') {}
      } else {
        Get.toNamed(Routes.feedDetail, arguments: item.id ?? 0);
      }
    },
    child: isMyPost
        ? Container(
            margin: EdgeInsets.fromLTRB(10.w, 12.w, 10.w, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12.rpx),
            ),
            child: child,
          )
        : LinearCard(
            padding: EdgeInsets.only(bottom: 2.w),
            margin: EdgeInsets.only(top: 10.w, left: 16.w, right: 16.w),
            child: child,
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
    padding: EdgeInsets.only(left: 8.w),
    child: Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(asset),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(2.w, 1.w, 2.w, 2.5.w),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.w,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget mediaContent(List<UploadFile> files) {
  int picCount = files.length;
  if (picCount == 1 && files[0].type == 'image') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: getFilesUrl(files[0]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 179.w,
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
              height: 179.w,
              placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
              errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
            ),
          ),
          Image.asset(
            'assets/images/play_btn.png',
            width: 32.w,
            height: 32.w,
          ),
        ],
      ),
    );
  } else if (picCount == 2) {
    return multipleImageWrap(2, files.map((e) => getFilesUrl(e)).toList());
  } else if (picCount >= 3) {
    return multipleImageWrap(3, files.map((e) => getFilesUrl(e)).toList());
  }
  return const SizedBox();
}

Widget multipleImageWrap(int imageCount, List<String> imgUrlList) {
  return LayoutBuilder(builder: (context, constraints) {
    final itemWidth = (constraints.maxWidth - 2 * 6.w) / imageCount;
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.w,
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
  return uploadFile.url ?? '';
}
