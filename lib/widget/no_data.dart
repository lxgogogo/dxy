import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

class NoDataView extends StatelessWidget {
  final String text;

  const NoDataView({super.key, this.text = '暂无数据'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/no_result.png', height: 204.w),
        SizedBox(
          height: 10.w,
        ),
        Text(
          text,
          style: TextStyle(
            color: '#333333'.hexColor.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }
}

class NoCommentView extends StatelessWidget {
  final String image;
  final String text;

  const NoCommentView({
    super.key,
    this.image = 'assets/images/no_comment.png',
    this.text = '还没有评论，快来发表第一个评论吧',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.w),
          child: Image.asset(
            image,
            height: 112.w,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: '#333333'.hexColor.withOpacity(0.5),
            fontSize: 12.sp,
          ),
        )
      ],
    );
  }
}
