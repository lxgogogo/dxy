import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/page/home/home_screen.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/track_utils.dart';

class HomeMenuSlideAnimation extends StatefulWidget {
  final Widget child;

  const HomeMenuSlideAnimation({Key? key, required this.child}) : super(key: key);

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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: '#F3F8FF'.hexColor.withOpacity(0.9),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                MenuItem(
                  name: '精彩视频',
                  nameEn: 'Video',
                  imagePath: Assets.images.iconHomeVideo.path,
                  onTap: TrackUtils.trackedTap(
                    onTap: () => Get.toNamed(Routes.videoList),
                    userLogType: '101002',
                  ),
                ),
                SizedBox(width: 6.w),
                MenuItem(
                  name: '互动课程',
                  nameEn: 'Course',
                  imagePath: Assets.images.iconHomeMainCourse.path,
                  onTap: () {
                    HomeController.of.changeMainTab(2);
                  },
                ),
                SizedBox(width: 6.w),
                MenuItem(
                  name: '德州教程',
                  nameEn: 'Tutorial',
                  imagePath: Assets.images.iconHomeCourse.path,
                  onTap: TrackUtils.trackedTap(
                    onTap: () => Get.toNamed(Routes.course),
                    userLogType: '101003',
                  ),
                ),
                SizedBox(width: 6.w),
                MenuItem(
                  name: '好书推荐',
                  nameEn: 'Recommend',
                  imagePath: Assets.images.iconHomeBook.path,
                  onTap: TrackUtils.trackedTap(
                    onTap: () => Get.toNamed(Routes.boolList),
                    userLogType: '101004',
                  ),
                ),
                // SizedBox(width: 6.w),
                // MenuItem(
                //   name: '实用工具',
                //   nameEn: 'Tools',
                //   imagePath: Assets.images.iconHomeTool.path,
                //   onTap: TrackUtils.trackedTap(
                //     onTap: () => Get.toNamed(Routes.toolList),
                //     userLogType: '101014',
                //   ),
                // ),
              ],
            ),
          ),
        ),
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
      child: SizedBox(
        width: 112.w,
        child: AspectRatio(
          aspectRatio: 112 / 32,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: '#0050FF'.hexColor.withOpacity(0.1),
                      offset: Offset(0, 3.27.w),
                      blurRadius: 6.54.r,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(32.r),
                ),
                padding: EdgeInsets.only(left: 12.w),
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: TextStyle(
                    color: '#1E1E1E'.hexColor,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  imagePath,
                  width: 42.w,
                  height: 42.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
