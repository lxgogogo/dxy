
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

class UserTerms extends StatelessWidget {
  final VoidCallback onTermsCheck;
  final ValueNotifier<bool> didAgreeTerms;
  final VoidCallback reviewTerms;
  final VoidCallback reviewPrivacy;

  const UserTerms({
    super.key,
    required this.onTermsCheck,
    required this.didAgreeTerms,
    required this.reviewTerms,
    required this.reviewPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: didAgreeTerms,
          builder: (
            BuildContext context,
            bool didAgreeTerms,
            Widget? child,
          ) {
            return InkWell(
              onTap: onTermsCheck,
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: didAgreeTerms ? '#249cfc'.hexColor : null,
                  border: didAgreeTerms
                      ? null
                      : Border.all(
                          color: const Color(0xFFD3D5DA),
                          width: 1.5.w,
                        ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: didAgreeTerms
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    : null,
              ),
            );
          },
        ),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '我同意德学院',
                  style: TextStyle(
                    color: '#3b5078'.hexColor,
                    fontSize: 14.sp,
                  ),
                ),
                TextSpan(
                  text: ' 用户协议 ',
                  recognizer: TapGestureRecognizer()..onTap = reviewTerms,
                  style: TextStyle(
                    color: '#249cfc'.hexColor,
                    fontSize: 14.sp,
                  ),
                ),
                TextSpan(
                  text: '和',
                  style: TextStyle(
                    color: '#3b5078'.hexColor,
                    fontSize: 14.sp,
                  ),
                ),
                TextSpan(
                  text: ' 隐私政策 ',
                  recognizer: TapGestureRecognizer()..onTap = reviewPrivacy,
                  style: TextStyle(
                    color: '#249cfc'.hexColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
