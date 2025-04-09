import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

class CommonAppBar {
  static AppBar arrowBack(
    BuildContext context, {
    String title = '',
        TextStyle ? titleStyle,
    VoidCallback? onBack,
    List<Widget>? actions,
    double? elevation,
    bool? centerTitle,
    bool hideArrow = false,
    Widget? flexibleSpace,
    Color? backgroundColor,
    Color? arrowColor,
    Color? titleColor,
    Widget? cusTitle,
    Widget? cusLeading,
    bool hideLeadingOnDesktop = false,
  }) =>
      AppBar(
        title: Text(
          title,
          style: titleStyle??TextStyle(
            fontSize: 14.sp,
            color: titleColor ?? '#333333'.hexColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.w,
            height: 22.w,
            color: arrowColor,
          ),
          onPressed: Get.back,
        ),
        actions: actions,
        backgroundColor: Colors.transparent,
      );
}
