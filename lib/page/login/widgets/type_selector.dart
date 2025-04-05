import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../login_screen.dart';
import 'login_content.dart';

class TypeSelector extends StatefulWidget {
  final List<String> typeList;
  final int typeIndex;
  final Function(int) onTypeSelected;

  const TypeSelector({
    super.key,
    required this.typeList,
    required this.typeIndex,
    required this.onTypeSelected,
  });

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  final SuperTooltipController _tipController = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      showBarrier: true,
      controller: _tipController,
      popupDirection: TooltipDirection.down,
      backgroundColor: Colors.transparent,
      hasShadow: false,
      borderColor: Colors.transparent,
      arrowLength: 0,
      arrowTipDistance: 22.w + 12.w,
      bubbleDimensions: EdgeInsets.zero,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      touchThroughAreaCornerRadius: 10,
      minimumOutsideMargin: 0,
      barrierColor: Colors.transparent,
      left: 12.w,
      right: 12.w,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12.r)),
          boxShadow: [
            BoxShadow(
              color: '557BF6'.hexColor.withOpacity(0.1),
              offset: Offset(0, 4.w),
              blurRadius: 4.r,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.typeList.length,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.typeList[index];
            return GestureDetector(
              onTap: () {
                if (widget.typeIndex != index) {
                  widget.onTypeSelected(index);
                  _tipController.hideTooltip();
                }
              },
              child: Container(
                height: 44.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: widget.typeIndex == index ? '#557BF6'.hexColor.withOpacity(0.2) : Colors.white,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _tipController.showTooltip();
        },
        child: Container(
          height: 44.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: '#557BF6'.hexColor),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.typeList[widget.typeIndex],
                  style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                ),
              ),
              SvgPicture.asset(
                Assets.svg.iconArrowDown,
                width: 20.w,
                height: 20.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
