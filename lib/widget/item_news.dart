import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/count_widget.dart';

class NewsItem extends StatelessWidget {
  final ArticleBean item;

  const NewsItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.type == 'video' || item.type == 'videoList') {
          Get.toNamed(Routes.videoDetail, arguments: {'id': item.id ?? 0});
          return;
        }
        Get.toNamed(Routes.articleDetail, arguments: item.id ?? 0);
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 16.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#000000'.hexColor.withOpacity(0.05))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 16.sp,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.w),
            if (item.pureText?.isNotEmpty == true)
              Text(
                item.pureText ?? '',
                style: TextStyle(
                  color: '#333333'.hexColor.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (item.cover?.isNotEmpty == true)
              Container(
                margin: EdgeInsets.only(top: 8.w),
                width: 160.w,
                height: 90.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: item.cover ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                  ),
                ),
              ),
            SizedBox(height: 8.w),
            Row(
              children: [
                SimpleCountText(
                  count: item.likeCount?.abbreviateNumber ?? '0',
                  desc: '点赞',
                ),
                const SimpleDot(),
                SimpleCountText(
                  count: item.commentCount?.abbreviateNumber ?? '0',
                  desc: '评论',
                ),
                const SimpleDot(),
                SimpleCountText(
                  count: item.favoriteCount?.abbreviateNumber ?? '0',
                  desc: '收藏',
                ),
                const SimpleDot(),
                SimpleCountText(
                  count: item.shareCount?.abbreviateNumber ?? '0',
                  desc: '分享',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
