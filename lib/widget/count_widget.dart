import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountComment extends StatelessWidget {
  const CountComment({
    super.key,
    required this.count,
    this.usePlaceHolder = true,
  });

  final String count;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/comment.png',
            width: 13.w,
          ),
          SizedBox(width: 6.w),
          CountText(count: count, usePlaceHolder: usePlaceHolder),
        ],
      ),
    );
  }
}

class CountFavorite extends StatelessWidget {
  const CountFavorite({
    super.key,
    required this.count,
    this.stared = false,
  });

  final String count;
  final bool stared;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            stared ? 'assets/images/stared.png' : 'assets/images/star.png',
            width: 13.w,
          ),
          SizedBox(width: 6.w),
          CountText(count: count),
        ],
      ),
    );
  }
}

class CountShare extends StatelessWidget {
  const CountShare({
    super.key,
    required this.count,
  });

  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/share.png',
            width: 13.w,
          ),
          SizedBox(width: 6.w),
          CountText(count: count),
        ],
      ),
    );
  }
}

class CountLike extends StatelessWidget {
  const CountLike({
    super.key,
    required this.count,
    this.liked = false,
  });

  final String count;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            liked ? 'assets/images/praised.png' : 'assets/images/praise.png',
            width: 13.w,
          ),
          SizedBox(width: 6.w),
          CountText(count: count),
        ],
      ),
    );
  }
}

class CountText extends StatelessWidget {
  const CountText({
    super.key,
    required this.count,
    this.usePlaceHolder = true,
  });

  final String count;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (usePlaceHolder)
          Opacity(
            opacity: 0,
            child: Text(
              '999.9T',
              style: TextStyle(
                color: const Color(0xff9CACC9),
                fontSize: 12.sp,
              ),
            ),
          ),
        Text(
          count,
          style: TextStyle(
            color: const Color(0xff9CACC9),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
