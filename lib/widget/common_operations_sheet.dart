import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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

class CommonOperationsSheet extends StatefulWidget {
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
  State<CommonOperationsSheet> createState() => _CommonOperationsSheetState();
}

class _CommonOperationsSheetState extends State<CommonOperationsSheet> {
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        if (widget.selectedIndex != null) {
          _scrollController.scrollToIndex(
            widget.selectedIndex!,
          );
        }
      }
    });
  }

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
              controller: _scrollController,
              physics:
                  widget.overflowWidget != null ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  return AutoScrollTag(
                    key: ValueKey(index),
                    index: index,
                    controller: _scrollController,
                    child: ScaleButtonWrapper(
                        onTap: () {
                          widget.onSelectItem(index);
                          Get.back();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
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
                          child: widget.itemBuilder != null
                              ? widget.itemBuilder!(index, widget.selectedIndex == index)
                              : Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: widget.selectedIndex == index ? ColorStyle.c557BF6 : '#666666'.hexColor,
                                    fontWeight: widget.selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        )),
                  );
                }),
                // children: [
                //   ...widget.items.map((e) {
                //     final index = widget.items.indexOf(e);
                //
                //   })
                // ],
              ),
            )),
        if (widget.overflowWidget != null) widget.overflowWidget!
      ],
    );
  }
}
