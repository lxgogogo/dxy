import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

class HomeMenuSlideAnimation extends StatefulWidget {
  final Widget child;
  final Function onEnd;

  const HomeMenuSlideAnimation({Key? key, required this.child, required this.onEnd}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeMenuSlideAnimationState();
}

class _HomeMenuSlideAnimationState extends State<HomeMenuSlideAnimation> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      builder: (context, offset, child) => FractionalTranslation(
          translation: offset,
          child: SizedBox(
            width: double.infinity,
            child: widget.child,
          ),
        ),
      child: widget.child,
    );
  }
}

class HomeMenu extends StatelessWidget {

  const HomeMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          MenuItem(
            name: '精彩视频',
            nameEn: 'Video',
            imagePath: Assets.images.iconHomeVideo.path,
          ),
          SizedBox(width: 6.w),
          MenuItem(
            name: '德州教程',
            nameEn: 'Tutorial',
            imagePath: Assets.images.iconHomeCourse.path,
          ),
          SizedBox(width: 6.w),
          MenuItem(
            name: '好书推荐',
            nameEn: 'Recommend',
            imagePath: Assets.images.iconHomeBook.path,
          ),
          SizedBox(width: 6.w),
          MenuItem(
            name: '火爆论坛',
            nameEn: 'BBS',
            imagePath: Assets.images.iconHomeFeed.path,
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.name,
    required this.nameEn,
    required this.imagePath,
    this.onTap,
  });

  final String name;
  final String nameEn;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.85, sigmaY: 10.85),
                child: Container(
                  width: 112.w,
                  height: 32.w,
                  padding: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: '#0050FF'.hexColor.withOpacity(0.1),
                        offset: Offset(0, 3.27.w),
                        blurRadius: 6.54.r,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: '#1E1E1E'.hexColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                imagePath,
                height: 42.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}