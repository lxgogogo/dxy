
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

class UserTermsUncheck extends StatelessWidget {
  final VoidCallback reviewTerms;
  final VoidCallback reviewPrivacy;

  const UserTermsUncheck({
    super.key,
    required this.reviewTerms,
    required this.reviewPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '德学院',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
              TextSpan(
                text: ' 用户协议 ',
                recognizer: TapGestureRecognizer()..onTap = reviewTerms,
                style: TextStyle(
                  color: '#557BF6'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
              TextSpan(
                text: '和',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
              TextSpan(
                text: ' 隐私政策 ',
                recognizer: TapGestureRecognizer()..onTap = reviewPrivacy,
                style: TextStyle(
                  color: '#557BF6'.hexColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
