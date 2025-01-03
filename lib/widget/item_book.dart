import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/linear_card.dart';

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
    SizeFit.initialize(context);
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.bookDetail, arguments: widget.article.id ?? 0)?.whenComplete(() {
          widget.article.viewCount = (widget.article.viewCount ?? 0) + 1;
          setState(() {});
        });
      },
      child: LinearCard(
        margin: EdgeInsets.only(top: 10.w, left: 16.w, right: 16.w, bottom: 2.w),
        padding: EdgeInsets.only(left: 15.w, right: 12.w, top: 10.w, bottom: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(right: 18.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3.w))),
              child: CachedNetworkImage(
                imageUrl: widget.article.cover ?? '',
                width: 51.w,
                height: 68.w,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.article.title ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: const Color(0xff2a2a2a), fontSize: 15.w, height: 1.3),
                  ),
                  SizedBox(
                    height: 4.w,
                  ),
                  Text(
                    widget.article.author ?? '',
                    maxLines: 1,
                    style: TextStyle(color: const Color(0xff5D6E8E), fontSize: 12.w, height: 1.2),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '阅读 ${widget.article.viewCount.abbreviateNumber}',
                          style: TextStyle(color: const Color(0xff9CACC9), fontSize: 12.sp),
                        ),
                      ),
                      Expanded(
                        child: CountComment(count: widget.article.commentCount.abbreviateNumber),
                      ),
                      Expanded(
                        child: CountFavorite(count: widget.article.favoriteCount.abbreviateNumber),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
