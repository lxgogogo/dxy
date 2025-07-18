import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

typedef AnimationBuilder = Widget Function(
  AnimationController controller,
  Widget child,
  AnimationParam animationParam,
);

class DialogUtil {
  static Future<void> dismiss() async {
    return SmartDialog.dismiss();
  }

  static Future<void> showLoading({
    String text = '',
  }) async {
    unFocusKeyBoard();
    dismiss();
    await SmartDialog.showLoading(
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.black.withOpacity(0.7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(
                radius: 12.r,
                color: Colors.white,
              ),
              if (text.isNotEmpty) ...[
                SizedBox(height: 4.w),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      clickMaskDismiss: false,
      maskColor: Colors.transparent,
    );
  }

  static Future<void> showToast(
    String msg, {
    SmartDialogController? controller,
    Duration? displayTime,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? consumeEvent,
    bool? debounce,
    SmartToastType? displayType,
    Widget? widget,
  }) async {
    if (msg.isEmpty) return;
    Widget toast;
    if (widget != null) {
      toast = widget;
    } else {
      toast = SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.black.withOpacity(0.7),
          ),
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.8,
          ),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
            ),
          ),
        ),
      );
    }

    return SmartDialog.showToast(
      msg,
      controller: controller,
      displayTime: displayTime,
      alignment: alignment ?? Alignment.center,
      clickMaskDismiss: clickMaskDismiss,
      animationType: animationType,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      maskColor: maskColor,
      maskWidget: maskWidget,
      consumeEvent: consumeEvent,
      debounce: debounce ?? true,
      displayType: displayType,
      builder: (_) => toast,
    );
  }

  static void unFocusKeyBoard() {
    final focusManager = WidgetsBinding.instance;
    if (focusManager.focusManager.primaryFocus != null) {
      focusManager.focusManager.primaryFocus!.unfocus();
    }
  }
}
