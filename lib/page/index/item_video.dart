import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/forum/media_helper.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../widget/linear_card.dart';

// ignore: must_be_immutable
class VideoItem extends StatefulWidget {
  ArticleBean article;
  bool isBanner;
  VideoItem({super.key, required this.article, this.isBanner = false});

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
          padding: EdgeInsets.only(bottom: 2.px),
          margin: EdgeInsets.only(
              left: widget.isBanner ? 12.px : 0,
              right: widget.isBanner ? 12.px : 0,
              top: widget.isBanner ? 12.px : 0),
          child: itemContent()),
    );
  }

  Widget itemContent() {
    return Column(
      children: [
        Container(
          width: widget.isBanner ? 351.px : 180.px,
          height: widget.isBanner ? 200.px : 120.px,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13.px),
              topRight: Radius.circular(13.px),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              MediaHelper().cacheLoadNetworkImage(
                  widget.article.cover ?? '',
                  widget.isBanner ? 351.px : 180.px,
                  widget.isBanner ? 200.px : 120.px),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: Color(0x66000000),
                    child: Center(
                      child: Image.asset('assets/images/video.png',
                          width: 26.px, height: 26.px),
                    ),
                  )),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4.px,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14.px,
                      ),
                      Text(
                        widget.article.viewCount!.toString()+'次播放',
                        style: TextStyle(color: Colors.white, fontSize: 10.px),
                      ),
                      const Spacer(),
                      Container(
                        height: 16.px,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 7.px),
                        decoration: BoxDecoration(
                            color: Color(0x66000000),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.px))),
                        child: Text(
                          formatDuration(
                              Duration(seconds: widget.article.duration ?? 0)),
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.px),
                        ),
                      ),
                      SizedBox(
                        width: 14.px,
                      ),
                    ],
                  )),
              if (widget.article.type == 'videoList')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.px, vertical: 8.px),
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
        Container(
          margin: EdgeInsets.only(left: 12.px, right: 12.px, top: widget.isBanner ? 10.px:7.px,bottom: widget.isBanner ? 10.px : 0),
          child: Text(
            widget.article.title ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: widget.isBanner ? 1:2,
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: widget.isBanner ? 14.px:12.px,
            ),
          ),
        ),
      ],
    );
  }
}
