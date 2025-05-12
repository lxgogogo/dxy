import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/widget/count_widget.dart';

import '../../../model/collect_page_model.dart';
import '../../../utils/date_util.dart';

class MyCollectItem extends StatelessWidget {
  final CollectModel? item;

  const MyCollectItem({
    super.key,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    String? title;
    String? content;
    String? author;
    DateTime? createdAt;
    int? likeCount;
    int? commentCount;
    int? favoriteCount;
    String? imageUrl;
    if (item?.relType == 'thread') {
      title = item?.thread?.title;
      // content = item?.thread?.content;
      content = item?.thread?.pureText;
      createdAt = item?.thread?.createdAt;
      likeCount = item?.thread?.likeCount;
      commentCount = item?.thread?.commentCount;
      favoriteCount = item?.thread?.favoriteCount;
      imageUrl = item?.thread?.files?.firstOrNull?.url;
    } else if (item?.relType == 'content') {
      title = item?.content?.title;
      content = item?.content?.description;
      author=item?.content?.author;
      createdAt = item?.content?.createdAt;
      likeCount = item?.content?.likeCount;
      commentCount = item?.content?.commentCount;
      favoriteCount = item?.content?.favoriteCount;
      imageUrl = item?.content?.cover;
    }
    final type = item?.content?.type;
    return GestureDetector(
      onTap: () {
        if (item?.id == null) return;
        if (item?.relType == 'thread') {
          final id = item?.thread?.id;
          if (id == null) return;
          Get.toNamed(Routes.feedDetail, arguments: id);
        } else if (item?.relType == 'content') {

          final id = item?.content?.id;
          if (id == null) return;
          if (type == 'article') {
            Get.toNamed(Routes.articleDetail, arguments: id);
          } else if (type == 'book') {
            Get.toNamed(Routes.bookDetail, arguments: id);
          } else if (type == 'tool') {
            Get.toNamed(Routes.toolDetail, arguments: id);
          } else if (type == 'video' || type == 'videoList') {
            Get.toNamed(Routes.videoDetail, arguments: {'id': id});
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#F2F2F2'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(type != 'book')
            Text(
              title ?? '',
              style: TextStyle(
                color: AppTheme.color_333333,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.w),
            SizedBox(
             // height: 66.w,
              child: Row(
                children: [
                  if (imageUrl?.isNotEmpty == true)
                    Container(
                      width:type == 'book'?68.w: 88.w,
                      height:type == 'book'?102.w: 66.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                            errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                          ),
                          if (item?.content?.type == 'videoList')
                            Positioned(
                              top: 2.w,
                              right: 2.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Text(
                                  '合集',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                     // width:type == 'book'?68.w: 88.w,
                      width: double.infinity,
                      height:type == 'book'?102.w: 66.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if(type == 'book')
                            ...[
                              Text(
                                title ?? '',
                                style: TextStyle(
                                  color: AppTheme.color_333333,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '作者:${author ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: '#333333'.hexColor.withOpacity(0.7),
                                    fontSize: 12.sp,
                                    height: 1.2),
                              ),
                            ],

                          Text(
                            content ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.color_666666,
                            ),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          Row(
                            children: [
                              Text(
                                DateUtil.formatDateAlias3(createdAt!.millisecondsSinceEpoch,),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.color_999999,
                                ),
                              ),
                              const Spacer(),
                              SimpleCountText(
                                count: likeCount?.abbreviateNumber ?? '0',
                                desc: '点赞',
                              ),
                              const SimpleDot(),
                              SimpleCountText(
                                count: commentCount?.abbreviateNumber ?? '0',
                                desc: '评论',
                              ),
                              // const SimpleDot(),
                              // SimpleCountText(
                              //   count: favoriteCount?.abbreviateNumber ?? '0',
                              //   desc: '收藏',
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
