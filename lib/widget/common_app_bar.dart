import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CommonAppBar {
  static AppBar arrowBack(
    BuildContext context, {
    String title = '',
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
          style: TextStyle(
            color: const Color(0xff2c2c2c),
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.w,
            height: 22.w,
          ),
          onPressed: Get.back,
        ),
        actions: actions,
        backgroundColor: Colors.transparent,
      );
}
