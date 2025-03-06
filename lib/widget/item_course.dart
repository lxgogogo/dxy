import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
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
    return Column(
      children: [
        ...List.generate(
          article.sublist?.length ?? 0,
          (i) {
            CollectBean collectBean = article.sublist![i];
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.articleDetail, arguments: collectBean.targetId ?? 0);
              },
              child: Container(
                height: 44.w,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                margin: EdgeInsets.only(bottom: 6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: '#0050FF'.hexColor.withOpacity(0.1),
                      offset: Offset(0, 5.w),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        collectBean.title!,
                        style: TextStyle(
                          color: '#132449'.hexColor.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      Assets.svg.iconArrow,
                      width: 14.w,
                      height: 14.w,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
