import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

class CommonAppBar {
  static AppBar arrowBack(
    BuildContext context, {
    String title = '',
    TextStyle? titleStyle,
    VoidCallback? onBack,
    List<Widget>? actions,
    double? elevation,
    bool? centerTitle,
    bool hideArrow = false,
    Widget? flexibleSpace,
    Color? arrowColor,
    Color? titleColor,
    Widget? cusTitle,
    Widget? cusLeading,
    bool hideLeadingOnDesktop = false,
    Color backgroundColor = Colors.transparent,
  }) =>
      AppBar(
        title: Text(
          title,
          style: titleStyle ??
              TextStyle(
                fontSize: 16.sp,
                color: titleColor ?? '#333333'.hexColor,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: Get.back,
          behavior: HitTestBehavior.translucent,
          child: Center(
            child: SvgPicture.asset(
              Assets.svg.iconBack,
              width: 24.w,
              height: 24.w,
              color: arrowColor,
            ),
          ),
        ),
        actions: actions,
        backgroundColor: backgroundColor,
        toolbarHeight: 56.w,
      );
}
