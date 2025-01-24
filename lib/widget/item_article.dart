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
import 'package:holdem/widget/linear_card.dart';

// ignore: must_be_immutable
class ArticleItem extends StatefulWidget {
  ArticleBean article;

  ArticleItem({super.key, required this.article});

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.article.type == 'video' || widget.article.type == 'videoList') {
          Get.toNamed(Routes.videoDetail, arguments: widget.article.id ?? 0);
          return;
        }
        Get.toNamed(Routes.articleDetail, arguments: widget.article.id ?? 0);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.only(top: 16.w , bottom: 12.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: '#E6E6E6'.hexColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.article.title ?? '',
              style: TextStyle(
                color: const Color(0xff2a2a2a),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.w),
            if (widget.article.pureText?.isNotEmpty == true)
              Text(
                widget.article.pureText ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: '#696969'.hexColor,
                ),
                softWrap: true,
              ),
            if (widget.article.cover?.isNotEmpty == true)
              Container(
                margin: EdgeInsets.only(top: 8.w),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.article.cover ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                      errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 8.w),
            Row(
              children: [
                CountLike(count: widget.article.likeCount?.abbreviateNumber ?? '0'),
                CountComment(count: widget.article.commentCount?.abbreviateNumber ?? '0'),
                CountFavorite(count: widget.article.favoriteCount?.abbreviateNumber ?? '0'),
                CountShare(count: widget.article.shareCount?.abbreviateNumber ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
