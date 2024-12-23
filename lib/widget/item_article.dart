import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/media_helper.dart';
import 'package:holdem/utils/size_fit.dart';
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
          margin: EdgeInsets.only(top: 10.w, left: 16.w, right: 16.w),
          padding: EdgeInsets.only(left: 20.w, right: 12.w, top: 5.w, bottom: 5.w),
          child: itemContent()),
    );
  }

  Widget itemContent() {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
          height: 80.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.article.title ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: const Color(0xff2a2a2a),
                  fontSize: 14.sp,
                ),
              ),
              // Spacer(),
              Row(
                children: [
                  Text(
                    widget.article.createdAt != null ? DateFormat('yyyy-MM-dd').format(widget.article.createdAt!) : '',
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Image.asset(
                    'assets/images/comment.png',
                    width: 13.w,
                    height: 12.w,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    widget.article.commentCount.toString(),
                    style: TextStyle(
                      color: const Color(0xff9CACC9),
                      fontSize: 12.sp,
                    ),
                  )
                ],
              )
            ],
          ),
        )),
        Container(
          width: 92.w,
          height: 66.w,
          margin: EdgeInsets.only(left: 15.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              MediaHelper().cacheLoadNetworkImage(widget.article.cover ?? '', 92.w, 66.w),
            ],
          ),
        )
      ],
    );
  }
}
