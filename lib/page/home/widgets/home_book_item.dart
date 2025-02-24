import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';

class HomeBookItem extends StatelessWidget {
  const HomeBookItem({
    super.key,
    required this.itemWidth,
    required this.item,
  });

  final double itemWidth;
  final ArticleBean item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.bookDetail,
          arguments: item.id,
        );
      },
      child: SizedBox(
        width: itemWidth,
        height: itemWidth / (170 / 216),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: '#58A5FF'.hexColor.withOpacity(0.1),
                    blurRadius: 4.r,
                    offset: Offset(0, 4.w),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.title ?? '',
                          style: TextStyle(
                            color: '#132449'.hexColor,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.w),
                        Text(
                          item.author ?? '',
                          style: TextStyle(
                            color: '#132449'.hexColor.withOpacity(0.7),
                            fontSize: 12.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.w),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: CachedNetworkImage(
                imageUrl: item.cover ?? '',
                width: 95.25.w,
                height: 122.27.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
