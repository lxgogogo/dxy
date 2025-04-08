import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import 'close_image_button.dart';

class DialogNewTip extends StatelessWidget {
  final String title;
  final String content;

  const DialogNewTip({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ShadowWrapper(
        borderRadius: 16.r,
        margin: EdgeInsets.symmetric(horizontal: 32.w),
        child: Container(
          padding: EdgeInsets.only(bottom: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 72.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CloseImageButton(
                        color: '#333333'.hexColor.withOpacity(0.5),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  content,
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 36.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      height: 33.w,
                      padding: EdgeInsets.symmetric(horizontal: 36.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            '#557BF6'.hexColor,
                            '#84BCF9'.hexColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '确定',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
