import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/routes/app_pages.dart';

class TagItem extends StatelessWidget {
  final TagModel tag;

  const TagItem({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.searchTag, arguments: {'tagId': tag.id});
      },
      child: Container(
        height: 44.w,
        margin: EdgeInsets.only(bottom: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: '#F8FBFF'.hexColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0, 1.w),
              blurRadius: 2.r,
              spreadRadius: 1.r,
            ),
            BoxShadow(
              color: '#B9D0E5'.hexColor.withOpacity(0.64),
              offset: Offset(0, -1.w),
              blurRadius: 2.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 3.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: '#249CFC'.hexColor,
                      borderRadius: BorderRadius.circular(1.5.r),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      tag.name ?? '',
                      style: TextStyle(
                        color: '#424242'.hexColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 1,
              child: Text(
                '浏览 ${tag.viewCount ?? 0}',
                style: TextStyle(
                  color: '#9CACC9'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/comment.png',
                    width: 13.w,
                    height: 13.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${tag.commentCount ?? 0}',
                    style: TextStyle(
                      color: '#9CACC9'.hexColor,
                      fontSize: 12.sp,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
