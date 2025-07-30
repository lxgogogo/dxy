import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/count_widget.dart';

class TagItem extends StatelessWidget {
  final TagModel tag;

  const TagItem({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.searchTag, arguments: {
          'tag': tag,
        });
      },
      child: Container(
        height: 44.w,
        margin: EdgeInsets.only(bottom: 12.w),
        padding: EdgeInsets.only(left: 12.w, right: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(12.r),
          ),
          boxShadow: [
            BoxShadow(
              color: 'b9d0e5'.hexColor.withOpacity(0.64),
              blurRadius: 2.r,
              offset: Offset(0, -1.w),
            ),
            BoxShadow(
              color: Colors.white,
              spreadRadius: 1.r,
              blurRadius: 2.r,
              offset: Offset(0, 1.w),
            ),
            BoxShadow(
              color: 'bfd2e2'.hexColor.withOpacity(0.81),
              blurRadius: 4.r,
              offset: Offset(0, 2.w),
            ),
            BoxShadow(
              color: 'f8fbff'.hexColor,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
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
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            CountView(count: tag.viewCount?.abbreviateNumber ?? '0'),
            CountComment(count: tag.commentCount?.abbreviateNumber ?? '0'),
          ],
        ),
      ),
    );
  }
}
