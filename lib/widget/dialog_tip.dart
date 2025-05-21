import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

class DialogTip extends StatelessWidget {
  final String title;
  final String content;

  const DialogTip({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ShadowWrapper(
          borderRadius: 10.5.r,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.only(top: 24.w, bottom: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff5f75a0),
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                  child: Text(
                    content,
                    style:  TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xff5f75a0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    height: 42.w,
                    title: '确认',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
