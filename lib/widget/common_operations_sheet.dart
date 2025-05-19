import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';

void showCommonOperationsSheet({
  required List<String> items,
  required Function(int index) onSelectItem,
}) {
  Get.bottomSheet(
    CommonOperationsSheet(
      items: items,
      onSelectItem: onSelectItem,
    ),
    barrierColor: Colors.black.withOpacity(0.4),
  );
}

class CommonOperationsSheet extends StatelessWidget {
  final List<String> items;
  final Function(int index) onSelectItem;

  const CommonOperationsSheet({
    super.key,
    required this.items,
    required this.onSelectItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 12.w, bottom: 34.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.map((e) {
                return GestureDetector(
                    onTap: () {
                      onSelectItem(items.indexOf(e));
                      Get.back();
                    },
                    child: Container(
                      height: 48.w,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.w,
                            color: ColorStyle.c333333.withOpacity(0.05),
                          ),
                        ),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.color_333333,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ));
              })
            ],
          ),
        ));
  }
}
