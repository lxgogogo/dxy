import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';

// ignore: must_be_immutable
class BookItem extends StatefulWidget {
  ArticleBean article;
  BookItem({super.key, required this.article});

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  itemContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.only(right: 18.px),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3.px))),
          child: Image.network(
            widget.article.cover ?? '',
            width: 51.px,
            height: 68.px,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.title ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  color: const Color(0xff2a2a2a), fontSize: 15.px, height: 1.3),
            ),
            SizedBox(
              height: 4.px,
            ),
            Text(
              widget.article.author ?? '',
              maxLines: 1,
              style: TextStyle(
                  color: const Color(0xff5D6E8E), fontSize: 12.px, height: 1.2),
            ),
            SizedBox(
              height: 10.px,
            ),
            Row(
              children: [
                SizedBox(
                  width: 115.px,
                  child: Text(
                    '阅读 '+widget.article.viewCount.toString(),
                    style: TextStyle(color: Color(0xff9CACC9), fontSize: 12.px),
                  ),
                ),
                SizedBox(
                  width: 70.px,
                  child: Row(
                    children: [
                      Image.asset('assets/images/comment.png',width: 11.px,height: 12.px,),
                      SizedBox(width: 4.px,),
                      Text(
                        widget.article.commentCount.toString(),
                        style: TextStyle(
                            color: Color(0xff9CACC9), fontSize: 12.px),
                      )
                    ],
                  ),
                ),
                Row(
                    children: [
                      Image.asset('assets/images/praise.png',width: 13.px,height: 12.px,),
                      SizedBox(width: 4.px,),
                      Text(
                        widget.article.likeCount.toString(),
                        style: TextStyle(
                            color: Color(0xff9CACC9), fontSize: 12.px),
                      )
                    ],
                  )
              ],
            )
          ],
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
            "/book_detail?id=${widget.article.id ?? 0}",
            arguments: widget.article.id ?? 0);
        // Get.to(BookDetailPage(id:widget.article.id ?? 0));
      },
      child: LinearCard(
          padding: EdgeInsets.only(bottom: 2.px),
          margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
          child: Container(
              padding: EdgeInsets.only(
                  left: 15.px, right: 12.px, top: 10.px, bottom: 12.px),
              decoration: BoxDecoration(
                //flutter 上下颜色渐变
                //#F9CF3A, #FFD43E00
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEEF7FE),
                    Color(0xFFFFFFFF),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(13.px)),
              ),
              child: itemContent())),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   SizeFit.initialize(context);
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.of(context).pushNamed(
  //             "/book_detail?id=${widget.article.id ?? 0}",
  //             arguments: widget.article.id ?? 0);
  //       // Get.to(BookDetailPage(id:widget.article.id ?? 0));
  //     },
  //     child: Container(
  //       clipBehavior: Clip.antiAlias,
  //       decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.all(Radius.circular(10.px))),
  //       child: Column(
  //         children: [
  //           Image.network(
  //             widget.article.cover ?? '',
  //             width: 172.px,
  //             height: 246.px,
  //             fit: BoxFit.cover,
  //           ),
  //           Expanded(
  //               child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 10.px),
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               widget.article.title ?? '',
  //               maxLines: 2,
  //               style: TextStyle(color: const Color(0xff3B5078),fontSize: 14.px),
  //             ),
  //           ))
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
