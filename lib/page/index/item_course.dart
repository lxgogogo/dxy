import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';

class CourseItem extends StatelessWidget {
  const CourseItem({
    super.key,
    required this.article,
  });

  final CourseBean article;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: EdgeInsets.only(bottom: 2.px),
      margin: EdgeInsets.only(top: 10.px, left: 18.px, right: 18.px, bottom: 10.px),
      child: Container(
        // padding: EdgeInsets.only(left: 20.px,right: 12.px,top:5.px,bottom: 5.px),
          decoration: BoxDecoration(
            color: const Color(0xffF8FBFF),
            borderRadius: BorderRadius.all(Radius.circular(13.px)),
          ),
          child: Column(
            children: [
              ...List.generate(article.sublist!.length, (i) {
                CollectBean collectBean = article.sublist![i];
                return GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.articleDetail, arguments: collectBean.targetId ?? 0);
                    },
                    child: Container(
                      height: 48.px,
                      padding: EdgeInsets.symmetric(horizontal: 20.px),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: i < article.sublist!.length - 1
                                      ? const Color(0xffe6e6e6)
                                      : Colors.transparent))),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                collectBean.title!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                          Image.asset(
                            'assets/images/arrow.png',
                            width: 6.px,
                            height: 10.px,
                          )
                        ],
                      ),
                    ));
              }),
            ],
          )),
    );
  }
}