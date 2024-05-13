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
        Get.to(const BookDetailPage());
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.px))),
        child: Column(
          children: [
            Image.network(
              'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
              width: 171.px,
              height: 145.px,
              fit: BoxFit.cover,
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.all(10.px),
              child: Text(
                'ELKY当今德州锦标赛打法转行德扑的…',
                maxLines: 2,
                style: TextStyle(color: Color(0xff3B5078)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
