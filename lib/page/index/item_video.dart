import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/page_article_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/size_fit.dart';

// ignore: must_be_immutable
class VideoItem extends StatefulWidget {
  ArticleBean article;
  VideoItem({super.key, required this.article});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {


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
          Get.to(VideoListPage(id: widget.article.id ?? 0));
          return;
        }
        if (widget.article.type == 'video') {
          Get.to(VideoDetailPage(id: widget.article.id ?? 0));
          return;
        }
        Get.to(ArticleDetailPage(id: widget.article.id ?? 0));
        // Get.to(VideoDetailPage(
        //   id: widget.article.id ?? 0,
        // ));
      },
      child: Container(
          padding: EdgeInsets.all(12.px),
          margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
          decoration: BoxDecoration(
            //flutter 上下颜色渐变
            //#F9CF3A, #FFD43E00
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEEF7FE),
                Color(0xFFFFFFFF),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(190, 214, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(194, 216, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
                // Color.fromRGBO(193, 215, 235, 1),
                // Color.fromRGBO(140, 190, 233, 1),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 4.0,
                spreadRadius: -4.0,
                offset: Offset(0.0, 6.0),
              ),
              // BoxShadow(
              //   color: Color.fromRGBO(148, 197, 239, 0.74),
              //   blurRadius: 9.4,
              //   spreadRadius: -9.4,
              //   offset: Offset(0.0, -4.0),
              // )
            ],
            borderRadius: BorderRadius.all(Radius.circular(13.px)),
          ),
          child: Row(
            children: [
              Container(
                width: 145.px,
                height: 120.px,
                margin: EdgeInsets.only(right: 15.px),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.px)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.network(
                      widget.article.cover ?? '',
                      width: 145.px,
                      height: 120.px,
                      fit: BoxFit.cover,
                    ),
                    if (widget.article.type == 'videoList')
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.px, vertical: 8.px),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.px),
                              bottomRight: Radius.circular(8.px),
                            ),
                          ),
                          child: Image.asset('assets/images/collection.png',
                              width: 13.px, height: 13.px),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                  child: SizedBox(
                height: 120.px,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.article.title ?? '',
                      maxLines: 3,
                      style: TextStyle(
                        color: const Color(0xff3B5078),
                        fontSize: 16.px,
                      ),
                    ),
                    // Spacer(),
                    if (widget.article.type != 'videoList')
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/time.png',
                            width: 20.px,
                            height: 20.px,
                          ),
                          SizedBox(
                            width: 5.px,
                          ),
                          Text(
                            widget.article.duration != null
                                ? formatDuration(Duration(seconds: widget.article.duration ?? 0))
                                : '',
                            style: TextStyle(
                              color: const Color(0xff666666),
                              fontSize: 14.px,
                            ),
                          ),
                          SizedBox(
                            width: 30.px,
                          ),
                          Image.asset(
                            'assets/images/comment.png',
                            width: 20.px,
                            height: 20.px,
                          ),
                          SizedBox(
                            width: 5.px,
                          ),
                          Text(
                            widget.article.commentCount.toString(),
                            style: TextStyle(
                              color: const Color(0xff666666),
                              fontSize: 14.px,
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ))
            ],
          )),
    );
  }
}
