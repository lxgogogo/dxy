import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import 'close_image_button.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final String? content;
  final VoidCallback? onConfirm;
  final String confirmText;
  final String cancelText;
  final bool onlyConfirm;
  final bool showClose;

  const CommonDialog({
    super.key,
    required this.title,
    this.content,
    this.onConfirm,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onlyConfirm = false,
    this.showClose = true
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !onlyConfirm,
      child: Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ShadowWrapper(
          borderRadius: 16.r,
          margin: EdgeInsets.only(left: 32.w, right: 32.w),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.w,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (showClose)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CloseImageButton(
                          color: '#333333'.hexColor.withOpacity(0.5),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                  ],
                ),
                if (content?.isNotEmpty ?? false)
                  Center(
                    child: Text(
                      content ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 26.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!onlyConfirm) ...[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 96.w,
                            height: 33.w,
                            decoration: ShapeDecoration(
                              color: '#333333'.hexColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                color: '#333333'.hexColor.withOpacity(0.7),
                                fontSize: 12.w,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 24.w),
                      ],
                      InkWell(
                        onTap: () {
                          onConfirm?.call();
                        },
                        child: Container(
                          width: 96.w,
                          height: 33.w,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(1.00, 0.00),
                              end: Alignment(-1, 0),
                              colors: [
                                Color(0xFF84BCF9),
                                Color(0xFF557BF6),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            confirmText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.w,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
