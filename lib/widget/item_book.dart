import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/linear_card.dart';

import '../utils/date_util.dart';

// ignore: must_be_immutable
class BookItem extends StatefulWidget {
  ArticleBean article;

  BookItem({super.key, required this.article});

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.bookDetail, arguments: widget.article.id ?? 0)?.whenComplete(() {
          widget.article.viewCount = (widget.article.viewCount ?? 0) + 1;
          setState(() {});
        });
      },
      child: Container(
        height: 132.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: '#58A5FF'.hexColor.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 4.w),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(right: 18.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.w))),
              child: CachedNetworkImage(
                imageUrl: widget.article.cover ?? '',
                width: 88.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.w),
                  Text(
                    widget.article.title ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: '#333333'.hexColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    '作者:${widget.article.author ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: '#333333'.hexColor.withOpacity(0.7),
                      fontSize: 12.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    widget.article.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: '#333333'.hexColor.withOpacity(0.7),
                      fontSize: 12.sp,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        widget.article.createdAt != null
                            ? DateUtil.formatDateAlias3(widget.article.createdAt!.millisecondsSinceEpoch)
                            : '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: '#333333'.hexColor.withOpacity(0.8),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        [
                          '${widget.article.likeCount?.abbreviateNumber}点赞',
                          '${widget.article.commentCount?.abbreviateNumber}评论',
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: '#333333'.hexColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
