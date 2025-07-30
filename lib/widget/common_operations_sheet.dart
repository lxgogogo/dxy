import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/color_style_util.dart';

import 'scale_button_wraper.dart';

void showCommonOperationsSheet(
    {required List<String> items,
    required Function(int index) onSelectItem,
    int? selectedIndex,
    double maxHeight = double.infinity,
    OperationItemBuilder? itemBuilder,
    Widget? overflowWidget,
    Function? endAction}) {
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CommonOperationsSheet(
        items: items,
        onSelectItem: onSelectItem,
        selectedIndex: selectedIndex,
        itemBuilder: itemBuilder,
        overflowWidget: overflowWidget,
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.4),
  ).whenComplete(() {
    if (endAction != null) {
      endAction();
    }
  });
}

typedef OperationItemBuilder = Widget Function(int index, bool hasSelected);

class CommonOperationsSheet extends StatelessWidget {
  final List<String> items;
  final Function(int index) onSelectItem;
  final int? selectedIndex;
  final OperationItemBuilder? itemBuilder;
  final Widget? overflowWidget;

  const CommonOperationsSheet(
      {super.key,
      required this.items,
      required this.onSelectItem,
      this.selectedIndex,
      this.itemBuilder,
      this.overflowWidget});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.only(top: 12.w, bottom: 34.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),
            ),
            child: SingleChildScrollView(
              physics: overflowWidget != null
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...items.map((e) {
                    final index = items.indexOf(e);
                    return ScaleButtonWrapper(
                        onTap: () {
                          onSelectItem(index);
                          Get.back();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                width: 1.w,
                                color: ColorStyle.c333333.withOpacity(0.05),
                              ),
                            ),
                          ),
                          child: itemBuilder != null
                              ? itemBuilder!(index, selectedIndex == index)
                              : Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: selectedIndex == index
                                        ? ColorStyle.c557BF6
                                        : '#666666'.hexColor,
                                    fontWeight: selectedIndex == index
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ));
                  })
                ],
              ),
            )),
        if (overflowWidget != null) overflowWidget!
      ],
    );
  }
}
