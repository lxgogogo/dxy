import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/home/widgets/home_book_item.dart';
import 'package:holdem/page/home/widgets/home_course_item.dart';
import 'package:holdem/page/home/widgets/home_nemu_item.dart';
import 'package:holdem/page/home/widgets/home_title.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/item_video.dart';

part 'home_controller.dart';

enum HomeType {
  news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course');

  final String title;

  final String categoryAlias;

  const HomeType(this.title, {required this.categoryAlias});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];
  late final TabController tabController;

  final List<String> types = ['news', 'video', 'book', 'course'];

  List<ArticleBean> articles = [];

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 48.w,
                margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Assets.images.logoText.image(width: 91.75.w),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.search);
                      },
                      child: SvgPicture.asset(
                        Assets.svg.iconSearch,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollNotification) {
                    if (scrollNotification is! ScrollUpdateNotification) {
                      return false;
                    }
                    final metrics = scrollNotification.metrics;
                    if ([AxisDirection.up, AxisDirection.down].contains(metrics.axisDirection)) {
                      controller.setPixels(metrics.pixels);
                    }
                    return false;
                  },
                  child: Stack(
                    children: <Widget>[
                      Assets.images.homeBanner.image(
                        height: 272.w,
                      ),
                      SingleChildScrollView(
                        controller: controller.scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 211.w),
                            ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: '#F3F8FF'.hexColor.withOpacity(0.7),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 24.w),
                                      LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          final itemWidth = (constraints.maxWidth - 12.w) / 2;
                                          return Wrap(
                                            spacing: 12.w,
                                            runSpacing: 24.w,
                                            children: [
                                              HomeMenuItem(
                                                itemWidth: itemWidth,
                                                name: '精彩视频',
                                                nameEn: 'Video',
                                                imagePath: Assets.images.iconHomeVideo.path,
                                              ),
                                              HomeMenuItem(
                                                itemWidth: itemWidth,
                                                name: '德州教程',
                                                nameEn: 'Tutorial',
                                                imagePath: Assets.images.iconHomeCourse.path,
                                              ),
                                              HomeMenuItem(
                                                itemWidth: itemWidth,
                                                name: '好书推荐',
                                                nameEn: 'Recommend',
                                                imagePath: Assets.images.iconHomeBook.path,
                                              ),
                                              HomeMenuItem(
                                                itemWidth: itemWidth,
                                                name: '火爆论坛',
                                                nameEn: 'BBS',
                                                imagePath: Assets.images.iconHomeFeed.path,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: 24.w),
                                      HomeTitle(
                                        title: '热门视频',
                                        subtitle: GestureDetector(
                                          child: Row(
                                            children: [
                                              Text(
                                                '换一批',
                                                style: TextStyle(
                                                  color: '#1E1E1E'.hexColor.withOpacity(0.5),
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              SizedBox(width: 3.w),
                                              SvgPicture.asset(
                                                Assets.svg.iconRefresh,
                                                width: 12.w,
                                                height: 12.w,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12.w),
                                      LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          final itemWidth = (constraints.maxWidth - 12.w) / 2;
                                          return Wrap(
                                            spacing: 12.w,
                                            runSpacing: 12.w,
                                            children: controller.videoItems
                                                .map((e) => SizedBox(
                                                      width: itemWidth,
                                                      child: VideoItem(item: e),
                                                    ))
                                                .toList(),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 12.w),
                                      HomeTitle(
                                        title: '精彩视频',
                                        onTap: controller.toVideoList,
                                      ),
                                      Column(
                                        children: controller.videoItems
                                            .map((e) => Padding(
                                                  padding: EdgeInsets.only(top: 6.w),
                                                  child: VideoHorizontalItem(item: e),
                                                ))
                                            .toList(),
                                      ),
                                      SizedBox(height: 24.w),
                                      const HomeTitle(
                                        title: '德州教程',
                                        subtitle: SizedBox(),
                                      ),
                                      SizedBox(height: 12.w),
                                      LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          final itemWidth = (constraints.maxWidth - 12.w) / 2;
                                          return Wrap(
                                            spacing: 12.w,
                                            runSpacing: 12.w,
                                            children: [
                                              HomeCourseItem(
                                                itemWidth: itemWidth,
                                                imagePath: Assets.images.course0.path,
                                                title: '菜鸟上路',
                                                subtitles: const [
                                                  'GTO上手',
                                                  '基础术语',
                                                  '牌桌礼仪',
                                                ],
                                              ),
                                              HomeCourseItem(
                                                itemWidth: itemWidth,
                                                imagePath: Assets.images.course1.path,
                                                title: '新手指导',
                                                subtitles: const [
                                                  '基础策略',
                                                  '算牌技巧',
                                                  '位置意识',
                                                ],
                                              ),
                                              HomeCourseItem(
                                                itemWidth: itemWidth,
                                                imagePath: Assets.images.course2.path,
                                                title: '进阶教程',
                                                subtitles: const [
                                                  '进阶升华',
                                                  '诈唬策略',
                                                  '下注尺度',
                                                ],
                                              ),
                                              HomeCourseItem(
                                                itemWidth: itemWidth,
                                                imagePath: Assets.images.course3.path,
                                                title: '职业打法',
                                                subtitles: const [
                                                  '多桌策略',
                                                  '诈唬进阶',
                                                  'GTO策略',
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: 24.w),
                                      const HomeTitle(title: '好书推荐'),
                                      SizedBox(height: 12.w),
                                      LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          final itemWidth = (constraints.maxWidth - 12.w) / 2;
                                          return Wrap(
                                            spacing: 12.w,
                                            runSpacing: 12.w,
                                            children: controller.bookItems
                                                .map(
                                                  (e) => HomeBookItem(
                                                    itemWidth: itemWidth,
                                                    item: e,
                                                  ),
                                                )
                                                .toList(),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 32.w),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
