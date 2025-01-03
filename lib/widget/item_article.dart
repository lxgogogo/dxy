import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/media_helper.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ArticleItem extends StatefulWidget {
  ArticleBean article;

  ArticleItem({super.key, required this.article});

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

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
      child: LinearCard(
        padding: EdgeInsets.only(bottom: 2.w),
        margin: EdgeInsets.only(top: 10.w, left: 16.w, right: 16.w),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.article.title ?? '',
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.article.description?.isNotEmpty == true)
                Text(
                  widget.article.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xff666666),
                  ),
                  softWrap: true,
                ),
              if (widget.article.cover?.isNotEmpty == true)
                Padding(
                  padding: EdgeInsets.only(top: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.article.cover ?? '',
                      fit: BoxFit.cover,
                      height: 180.w,
                      placeholder: (context, url) => Center(
                        child: Assets.images.imageLoadingDef.image(),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Assets.images.imageLoadingDef.image(),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.w),
              Row(
                children: [
                  Expanded(
                    child: CountLike(count: widget.article.likeCount?.abbreviateNumber ?? '0'),
                  ),
                  Expanded(
                    child: CountComment(count: widget.article.commentCount?.abbreviateNumber ?? '0'),
                  ),
                  Expanded(
                    child: CountFavorite(count: widget.article.favoriteCount?.abbreviateNumber ?? '0'),
                  ),
                  Expanded(
                    child: CountShare(count: widget.article.shareCount?.abbreviateNumber ?? '0'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
