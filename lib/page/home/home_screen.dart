import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/model/video_bean.dart';
import 'package:holdem/page/home/widgets/home_course_item.dart';
import 'package:holdem/page/home/widgets/home_menu_animation.dart';
import 'package:holdem/page/home/widgets/home_nemu_item.dart';
import 'package:holdem/page/home/widgets/home_tag_list_widget.dart';
import 'package:holdem/page/home/widgets/home_title.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/three_d_book_item.dart';
import 'package:holdem/widget/transparent_pointer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/banner.dart';
import '../../model/home_hot_tag_model.dart';
import '../../services/home_service.dart';
import '../../stores/user_store.dart';
import '../../utils/event_bus_util.dart';
import '../../utils/track_utils.dart';

part 'home_controller.dart';

enum SourceType {
  // news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course'),
  feed('帖子', categoryAlias: 'feed'),
  tool('工具', categoryAlias: 'tool');

  final String title;

  final String categoryAlias;

  const SourceType(this.title, {required this.categoryAlias});
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
                      onTap: TrackUtils.trackedTap(
                        onTap: () => Get.toNamed(Routes.search),
                        userLogType: '100006',
                      ),
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
                child: Stack(
                  children: <Widget>[
                    if (controller.banners.isNotEmpty)
                      SizedBox(
                        height: 234.w,
                        child: Stack(
                          children: [
                            Builder(
                              builder: (context) {
                                for (final banner in controller.banners) {
                                  precacheImage(
                                    CachedNetworkImageProvider(banner.imgMobile ?? '',
                                        cacheKey: banner.imgMobile ?? ''),
                                    context,
                                  );
                                }
                                return SizedBox(
                                  height: 234.w,
                                  child: Swiper(
                                    itemCount: controller.banners.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: TrackUtils.trackedTap(
                                          onTap: controller.jumpPage,
                                          userLogType: '101001',
                                          params: controller.banners[index].jumpValue,
                                        ),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: controller.banners[index].imgMobile ?? '',
                                          fadeOutDuration: Duration.zero,
                                          fadeInDuration: Duration.zero,
                                          cacheKey: controller.banners[index].imgMobile ?? '',
                                          placeholder: (context, url) => Assets.images.imageLoadingDef.image(
                                            fit: BoxFit.fill,
                                          ),
                                          errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                    autoplay: true,
                                    onIndexChanged: controller.onIndexChanged,
                                  ),
                                );
                              },
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: controller.isShowHomeMenu ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          '#DCE8FE'.hexColor,
                                          '#F3F8FF'.hexColor,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TransparentPointer(
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 211.w),
                            GestureDetector(
                              onTap: () {},
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: '#F3F8FF'.hexColor,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12.r),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 24.w),
                                        AnimatedOpacity(
                                          opacity: controller.isShowHomeMenu ? 0 : 1,
                                          duration: const Duration(milliseconds: 300),
                                          child: LayoutBuilder(
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
                                                    onTap: TrackUtils.trackedTap(
                                                      onTap: () => Get.toNamed(Routes.videoList),
                                                      userLogType: '101002',
                                                    ),
                                                  ),
                                                  HomeMenuItem(
                                                    itemWidth: itemWidth,
                                                    name: '德州教程',
                                                    nameEn: 'Tutorial',
                                                    imagePath: Assets.images.iconHomeCourse.path,
                                                    onTap: TrackUtils.trackedTap(
                                                      onTap: () => Get.toNamed(Routes.course),
                                                      userLogType: '101003',
                                                    ),
                                                  ),
                                                  HomeMenuItem(
                                                    itemWidth: itemWidth,
                                                    name: '好书推荐',
                                                    nameEn: 'Recommend',
                                                    imagePath: Assets.images.iconHomeBook.path,
                                                    onTap: TrackUtils.trackedTap(
                                                      onTap: () => Get.toNamed(Routes.boolList),
                                                      userLogType: '101004',
                                                    ),
                                                  ),
                                                  HomeMenuItem(
                                                    itemWidth: itemWidth,
                                                    name: '实用工具',
                                                    nameEn: 'Tools',
                                                    imagePath: Assets.images.iconHomeTool.path,
                                                    onTap: TrackUtils.trackedTap(
                                                      onTap: () => Get.toNamed(Routes.toolList),
                                                      userLogType: '101014',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 24.w),
                                        HomeTitle(
                                          title: '热门视频',
                                          subtitle: GestureDetector(
                                            onTap: TrackUtils.trackedTap(
                                              onTap: controller.loadHotVideos,
                                              userLogType: '101007',
                                            ),
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
                                                AnimatedBuilder(
                                                  animation: controller.animationController,
                                                  builder: (context, child) {
                                                    return Transform.rotate(
                                                      angle: controller.isHotVideosLoading
                                                          ? controller.animationController.value * 2 * pi
                                                          : 0,
                                                      child: SvgPicture.asset(
                                                        Assets.svg.iconRefresh,
                                                        width: 12.w,
                                                        height: 12.w,
                                                      ),
                                                    );
                                                  },
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
                                              children: controller.hotVideos
                                                  .map(
                                                    (e) => SizedBox(
                                                      width: itemWidth,
                                                      child: VideoItem(
                                                        onTap: () => TrackUtils.trackEvent(userLogType: '101006', params: e.id),
                                                        item: ArticleBean(
                                                          id: e.id,
                                                          cover: e.cover,
                                                          viewCount: e.viewCount,
                                                          duration: e.duration,
                                                          title: e.title,
                                                          createdAt: e.createdAt,
                                                          type: e.type,
                                                          likeCount: e.likeCount,
                                                          commentCount: e.commentCount,
                                                          featured: e.featured
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 12.w),
                                        HomeTagListWidget(tagList: controller.tagList, tagOnTap: controller.tagOnTap),
                                        SizedBox(height: 10.w),
                                        Column(
                                          children: controller.videoItems
                                              .map((e) => Padding(
                                                    padding: EdgeInsets.only(top: 6.w),
                                                    child: VideoHorizontalItem(
                                                      item: e,
                                                      onTap: () => TrackUtils.trackEvent(userLogType: '101008', params: e.id),
                                                    ),
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
                                                // 菜鸟上路：基础术语、牌桌礼仪、牌型计算
                                                // 新手指导：基础策略、算牌技巧、位置意识
                                                // 进阶教程：GTO上手、诈唬策略、下注尺度
                                                // 职业打法：多桌牌局、进阶诈唬、GTO策略
                                                HomeCourseItem(
                                                  itemWidth: itemWidth,
                                                  imagePath: Assets.images.course0.path,
                                                  title: '菜鸟上路',
                                                  subtitles: const [
                                                    '基础术语',
                                                    '牌桌礼仪',
                                                    '牌型计算',
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
                                                    'GTO上手',
                                                    '诈唬策略',
                                                    '下注尺度',
                                                  ],
                                                ),
                                                HomeCourseItem(
                                                  itemWidth: itemWidth,
                                                  imagePath: Assets.images.course3.path,
                                                  title: '职业打法',
                                                  subtitles: const [
                                                    '多桌牌局',
                                                    '进阶诈唬',
                                                    'GTO策略',
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        SizedBox(height: 24.w),
                                        HomeTitle(
                                          title: '好书推荐',
                                          onTap: TrackUtils.trackedTap(
                                            onTap: () => Get.toNamed(Routes.boolList),
                                            userLogType: '101013',
                                          ),
                                        ),
                                        SizedBox(height: 12.w),
                                        LayoutBuilder(
                                          builder: (BuildContext context, BoxConstraints constraints) {
                                            final itemWidth = (constraints.maxWidth - 12.w) / 2;
                                            return Wrap(
                                              spacing: 12.w,
                                              runSpacing: 12.w,
                                              children: controller.bookItems
                                                  .map((e) => ThreeDBookItem(
                                                      itemWidth: itemWidth,
                                                      item: e,
                                                      onTap: () => TrackUtils.trackEvent(userLogType: '101012', params: e.id)))
                                                  .toList(),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 32.w),
                                        SizedBox(
                                          height: kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (controller.isShowHomeMenu)
                      const HomeMenuSlideAnimation(
                        child: HomeMenu(),
                      ),
                  ],
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
