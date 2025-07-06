import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:lottie/lottie.dart';

import '../../../gen/assets.gen.dart';
import '../../../model/article_detail.dart';

void showVideoChildListSheet({
  required List<VideoBean> items,
  required Function(int index) onSelectItem,
  int? selectedIndex,
}) {
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 559.w),
      child: VideoChildListSheet(
        items: items,
        onSelectItem: onSelectItem,
        selectedIndex: selectedIndex,
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.4),
  );
}

class VideoChildListSheet extends StatelessWidget {
  final List<VideoBean> items;
  final Function(int index) onSelectItem;
  final int? selectedIndex;

  const VideoChildListSheet({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '选集',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: '#333333'.hexColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.w),
              ...items.map((e) {
                final index = items.indexOf(e);
                return GestureDetector(
                    onTap: () {
                      onSelectItem(index);
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.w,
                            color: ColorStyle.c333333.withOpacity(0.05),
                          ),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (selectedIndex == index)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Lottie.asset(
                                    Assets.lottie.playVideo,
                                    width: 16.w,
                                    repeat: true,
                                  ),
                                ),
                              ),
                            TextSpan(
                              text: e.title ?? '',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: selectedIndex == index ? '#557BF6'.hexColor : '#666666'.hexColor,
                                fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // child: Text(
                      //   e,
                      //   style: TextStyle(
                      //     fontSize: 16.sp,
                      //     color: selectedIndex == index ? '#333333'.hexColor : '#666666'.hexColor,
                      //     fontWeight: selectedIndex == index ? FontWeight.w500 : FontWeight.w400,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ));
              })
            ],
          ),
        ));
  }
}
