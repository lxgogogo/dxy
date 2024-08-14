import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/forum/media_helper.dart';
import 'package:holdem/page/index/page_article_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
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
    SizeFit.initialize(context);
    return GestureDetector(
      onTap: () {
        if (widget.article.type == 'videoList') {
          // Get.to(VideoListPage(id: widget.article.id ?? 0));
          Navigator.of(context).pushNamed(
              "/video_list?id=${widget.article.id ?? 0}",
              arguments: widget.article.id ?? 0);
          return;
        }
        if (widget.article.type == 'video') {
          // Get.to(VideoDetailPage(id: widget.article.id ?? 0));
          Navigator.of(context).pushNamed(
              "/video_detail?id=${widget.article.id ?? 0}",
              arguments: widget.article.id ?? 0);
          return;
        }
        Navigator.of(context).pushNamed(
            "/article_detail?id=${widget.article.id ?? 0}",
            arguments: widget.article.id ?? 0);
        // Get.to(ArticleDetailPage(id: widget.article.id ?? 0));
      },
      child: LinearCard(
        margin:EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
        padding: EdgeInsets.only(
              left: 20.px, right: 12.px, top: 5.px, bottom: 5.px),
        child: itemContent()),

      // child: Container(
      //     padding: EdgeInsets.only(bottom: 2.px),
      //     margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
      //     decoration: BoxDecoration(
      //       //flutter 上下颜色渐变
      //       //#F9CF3A, #FFD43E00
      //       borderRadius: BorderRadius.all(Radius.circular(13.px)),
      //       gradient: const LinearGradient(
      //         begin: Alignment.centerLeft,
      //         end: Alignment.centerRight,
      //         colors: [
      //           Color(0xFF7FA3C1),
      //           Color(0xFFBED6EB),
      //           Color(0xFF80A3C1),
      //           Color(0xFFC2D8EB),
      //           Color(0xFF80A3C1),
      //           Color(0xFFC1D7EB),
      //           Color(0xFF87A9C5)
      //         ],
      //       ),
      //     ),
      //     child: Container(
      //         padding: EdgeInsets.only(left: 20.px,right: 12.px,top:5.px,bottom: 5.px),
      //         decoration: BoxDecoration(
      //           //flutter 上下颜色渐变
      //           //#F9CF3A, #FFD43E00
      //           gradient: const LinearGradient(
      //             begin: Alignment.topCenter,
      //             end: Alignment.bottomCenter,
      //             colors: [
      //               Color(0xFFEEF7FE),
      //               Color(0xFFFFFFFF),
      //             ],
      //           ),
      //           borderRadius: BorderRadius.all(Radius.circular(13.px)),
      //         ),
      //         child: itemContent())),
    );
  }

  Widget itemContent() {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
          height: 80.px,
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
                  fontSize: 14.px,
                ),
              ),
              // Spacer(),
              if (widget.article.type != 'videoList')
                Row(
                  children: [
                    // Image.asset(
                    //   'assets/images/time.png',
                    //   width: 20.px,
                    //   height: 20.px,
                    // ),
                    // SizedBox(
                    //   width: 5.px,
                    // ),
                    Text(
                      DateFormat('M月d日')
                          .format(widget.article.createdAt ?? DateTime.now()),
                      // widget.article.duration != null
                      //     ? formatDuration(Duration(seconds: widget.article.duration ?? 0))
                      //     : '',
                      style: TextStyle(
                        color: const Color(0xff9CACC9),
                        fontSize: 12.px,
                      ),
                    ),
                    SizedBox(
                      width: 30.px,
                    ),
                    Image.asset(
                      'assets/images/comment.png',
                      width: 13.px,
                      height: 12.px,
                    ),
                    SizedBox(
                      width: 5.px,
                    ),
                    Text(
                      widget.article.commentCount.toString(),
                      style: TextStyle(
                        color: const Color(0xff9CACC9),
                        fontSize: 12.px,
                      ),
                    )
                  ],
                )
            ],
          ),
        )),
        Container(
          width: 92.px,
          height: 66.px,
          margin: EdgeInsets.only(left: 15.px),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.px)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              MediaHelper().cacheLoadNetworkImage(
                  widget.article.cover ?? '', 92.px, 66.px),
            ],
          ),
        )
      ],
    );
  }
}
