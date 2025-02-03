import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoDataView extends StatelessWidget {
  final String text;

  const NoDataView({super.key, this.text = '暂无数据'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_result.png', height: 102.w),
        SizedBox(
          height: 10.w,
        ),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xff3b5078),
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }
}
