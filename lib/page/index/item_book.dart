import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/utils/size_fit.dart';

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
        Get.to(BookDetailPage(id:widget.article.id ?? 0));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.px))),
        child: Column(
          children: [
            Image.network(
              widget.article.cover ?? '',
              width: 172.px,
              height: 246.px,
              fit: BoxFit.cover,
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.px),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.article.title ?? '',
                maxLines: 2,
                style: TextStyle(color: Color(0xff3B5078),fontSize: 14.px),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
