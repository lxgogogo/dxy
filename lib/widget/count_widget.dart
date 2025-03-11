import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import 'like_button/like_button.dart';
import 'package:badges/badges.dart' as badges;

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
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.svg.iconComment,
            width: 12.w,
          ),
          SizedBox(width: 3.w),
          CountText(count: count, usePlaceHolder: usePlaceHolder),
        ],
      ),
    );
  }
}

class CountReply extends StatelessWidget {
  const CountReply({super.key, required this.count, this.usePlaceHolder = true, this.iconWidget});

  final String count;
  final bool usePlaceHolder;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ??
              SvgPicture.asset(
                Assets.svg.iconComment,
                color: '#333333'.hexColor.withOpacity(0.7),
                width: 14.w,
              ),
          SizedBox(width: 4.w),
          Text(
            '回复',
            style: TextStyle(
              color: '#333333'.hexColor.withOpacity(0.7),
            ),
          )
          //  CountText(count: count, usePlaceHolder: usePlaceHolder),
        ],
      ),
    );
  }
}

class CountCommentBadge extends StatelessWidget {
  const CountCommentBadge({
    super.key,
    required this.count,
    required this.iconWidget,
  });

  final String count;
  final Widget iconWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            iconWidget,
            Transform.translate(
              offset: Offset(-8.w, -12.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: '##333333'.hexColor.withOpacity(0.7),
                    fontSize: 10.sp,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -10, end: -12),
      showBadge: true,
      ignorePointer: false,
      onTap: () {},
      badgeContent: Text(
        count,
        style: TextStyle(
          color: '##333333'.hexColor.withOpacity(0.7),
        ),
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.square,
        badgeColor: Colors.white,
        borderRadius: BorderRadius.circular(50),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        elevation: 0,
      ),
      child: iconWidget,
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
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          stared ? SvgPicture.asset(Assets.svg.stared) : SvgPicture.asset(Assets.svg.star),
          SizedBox(width: 3.w),
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
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/share.png',
            width: 11.w,
          ),
          SizedBox(width: 3.w),
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
    this.usePlaceHolder = true,
  });

  final String count;
  final bool liked;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            liked ? Assets.svg.iconLike : Assets.svg.iconLike,
            width: 12.w,
          ),
          SizedBox(width: 3.w),
          CountText(count: count, usePlaceHolder: usePlaceHolder),
        ],
      ),
    );
  }
}

class CountLikeAni extends StatefulWidget {
  const CountLikeAni(
      {super.key,
      required this.count,
      this.liked = false,
      this.usePlaceHolder = true,
      this.onToggleLike,
      this.likeWidget});

  final String count;
  final bool liked;
  final bool usePlaceHolder;
  final Function? onToggleLike;
  final Widget? likeWidget;

  @override
  State<CountLikeAni> createState() => _CountLikeAniState();
}

class _CountLikeAniState extends State<CountLikeAni> {
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    final success = await widget.onToggleLike?.call();
    return success ? !isLiked : isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LikeButton(
            isLiked: widget.liked,
            size: 24.w,
            padding: EdgeInsets.zero,
            onTap: onLikeButtonTapped,
            likeBuilder: (bool isLiked) {
              return widget.likeWidget ??
                  Image.asset(
                    isLiked ? 'assets/images/praised.png' : 'assets/images/praise.png',
                  );
            },
            likeCountPadding: EdgeInsets.only(left: 0.w),
            countBuilder: (_, __, ___) => widget.count.isEmpty
                ? const SizedBox()
                : CountText(
                    count: widget.count,
                    usePlaceHolder: widget.usePlaceHolder,
                  ),
          ),
        ],
      ),
    );
  }
}

class CountView extends StatelessWidget {
  const CountView({
    super.key,
    required this.count,
    this.usePlaceHolder = true,
  });

  final String count;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/eye_open.png',
            width: 11.w,
            color: const Color(0xff9CACC9),
          ),
          SizedBox(width: 3.w),
          CountText(count: count, usePlaceHolder: usePlaceHolder),
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
        if (usePlaceHolder) ...[
          IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: Text(
                '000.0M',
                style: TextStyle(
                  color: '#333333'.hexColor.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0,
            child: Text(
              '000',
              style: TextStyle(
                color: const Color(0xff9CACC9),
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
        Text(
          count,
          style: TextStyle(
            color: '#333333'.hexColor.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class SimpleCountText extends StatelessWidget {
  const SimpleCountText({
    super.key,
    required this.count,
    required this.desc,
    this.descStyle,
    this.usePlaceHolder = false,
  });

  final String count;
  final String desc;
  final TextStyle? descStyle;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (usePlaceHolder) ...[
          IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: Row(
                children: [
                  Text(
                    '000.0M',
                    style: TextStyle(
                      color: '#333333'.hexColor.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    desc,
                    style: descStyle ??
                        TextStyle(
                          color: const Color(0xff999999),
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0,
            child: Row(
              children: [
                Text(
                  '000',
                  style: TextStyle(
                    color: const Color(0xff9CACC9),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  desc,
                  style: descStyle ??
                      TextStyle(
                        color: const Color(0xff999999),
                        fontSize: 12.sp,
                      ),
                ),
              ],
            ),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                color: const Color(0xff999999),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              desc,
              style: descStyle ??
                  TextStyle(
                    color: const Color(0xff999999),
                    fontSize: 12.sp,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class SimpleCountTextReverse extends StatelessWidget {
  const SimpleCountTextReverse({
    super.key,
    required this.count,
    required this.desc,
    this.descStyle,
    this.usePlaceHolder = false,
  });

  final String count;
  final String desc;
  final TextStyle? descStyle;
  final bool usePlaceHolder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (usePlaceHolder) ...[
          Opacity(
            opacity: 0,
            child: Row(
              children: [
                Text(
                  '000',
                  style: TextStyle(
                    color: const Color(0xff9CACC9),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  desc,
                  style: descStyle ??
                      TextStyle(
                        color: const Color(0xff999999),
                        fontSize: 12.sp,
                      ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: Row(
                children: [
                  Text(
                    '000.0M',
                    style: TextStyle(
                      color: '#333333'.hexColor.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    desc,
                    style: descStyle ??
                        TextStyle(
                          color: const Color(0xff999999),
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              desc,
              style: descStyle ??
                  TextStyle(
                    color: const Color(0xff999999),
                    fontSize: 12.sp,
                  ),
            ),
            SizedBox(width: 2.w),
            Text(
              count,
              style: TextStyle(
                color: const Color(0xff999999),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SimpleDot extends StatelessWidget {
  const SimpleDot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        '·',
        style: TextStyle(
          color: const Color(0xff999999),
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
