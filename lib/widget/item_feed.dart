import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/linear_card.dart';

import '../gen/assets.gen.dart';
import '../model/board_list.dart';

class FeedItem extends StatelessWidget {
  final BoardBean item;
  final bool isMyPost;

  const FeedItem(
    this.item, {
    super.key,
    this.isMyPost = false,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Row(
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
              )
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            item.title ?? '',
            style: TextStyle(
              color: const Color(0xff2a2a2a),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.pureText?.isNotEmpty == true)
            Text(
              item.pureText ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xff666666),
              ),
              softWrap: true,
            ),
          if (item.files?.isNotEmpty == true)
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final itemWidth = (constraints.maxWidth - 12.w * 2) / 2.2;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(top: 8.w),
                  child: Row(
                    children: List.generate(
                      item.files?.length ?? 0,
                      (index) {
                        final fileItem = item.files![index];
                        return Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: getFilesUrl(fileItem),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Center(
                                    child: Assets.images.imageLoadingDef.image(),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Assets.images.imageLoadingDef.image(),
                                  ),
                                ),
                                if (fileItem.type == 'video')
                                  Center(
                                    child: Assets.images.playBtn.image(
                                      width: 32.w,
                                      height: 32.w,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: 16.w),
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/share.png',
                      width: 13.w,
                      height: 13.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${item.shareCount ?? 0}',
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

  String getFilesUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
      return uploadFile.posterUrl!;
    }
    return uploadFile.url ?? '';
  }
}
