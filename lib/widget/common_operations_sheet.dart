import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';

void showCommonOperationsSheet({
  required List<String> items,
  required Function(int index) onSelectItem,
  int? selectedIndex,
  double maxHeight = double.infinity,
}) {
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CommonOperationsSheet(
        items: items,
        onSelectItem: onSelectItem,
        selectedIndex: selectedIndex,
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.4),
  );
}

class CommonOperationsSheet extends StatelessWidget {
  final List<String> items;
  final Function(int index) onSelectItem;
  final int? selectedIndex;

  const CommonOperationsSheet({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.selectedIndex,
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
                final index = items.indexOf(e);
                return GestureDetector(
                    onTap: () {
                      onSelectItem(items.indexOf(e));
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
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
                          color: selectedIndex == index ? '#333333'.hexColor : '#666666'.hexColor,
                          fontWeight: selectedIndex == index ? FontWeight.w500 : FontWeight.w400,
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
