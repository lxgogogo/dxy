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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 12,
                color: Colors.white,
              ),
              if (text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.8,
          ),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
      displayType: displayType ?? SmartToastType.onlyRefresh,
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
