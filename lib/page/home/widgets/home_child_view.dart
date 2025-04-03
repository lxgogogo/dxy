import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/competition_loop.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/home/widgets/home_marquee_widget.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/item_news.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_course.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'home_child_controller.dart';

class HomeChildView extends StatelessWidget {
  final HomeType type;

  const HomeChildView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeChildController>(
      global: false,
      init: HomeChildController(type),
      builder: (controller) {
        switch (type) {
          case HomeType.news:
            return _buildNewsView(controller);
          case HomeType.video:
            return _buildVideoView(controller);
          case HomeType.book:
            return _buildBookView(controller);
          case HomeType.course:
            return _buildCourseView(controller);
        }
      },
    );
  }

  Widget _buildNewsView(HomeChildController controller) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoading,
      child: CustomScrollView(
        slivers: [
          if (controller.banners.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    for (final banner in controller.banners) {
                      precacheImage(
                        CachedNetworkImageProvider(banner.imgMobile ?? '', cacheKey: banner.imgMobile ?? ''),
                        context,
                      );
                    }
                    return SizedBox(
                      height: constraints.maxWidth / (1200 / 500) + 20.w,
                      child: Swiper(
                        itemCount: controller.banners.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              jumpPage(controller.banners[index]);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20.w),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
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
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                        pagination: SwiperPagination(
                          builder: SwiperCustomPagination(
                            builder: (context, config) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  config.itemCount,
                                  (index) => Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: config.activeIndex == index ? 20.w : 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        color: config.activeIndex == index
                                            ? const Color(0xff008EFF)
                                            : const Color(0xffADCCE8),
                                        borderRadius: BorderRadius.circular(3.r),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        autoplay: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          if (controller.loops.isNotEmpty)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.competitionCalendar);
                },
                child: Container(
                  width: 361.w,
                  height: 85.w,
                  padding: EdgeInsets.only(left: 60.w, right: 60.w, top: 20.w, bottom: 10.w),
                  decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/game.png'), fit: BoxFit.fill)),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0,
                        child: Text(
                          controller.loops.firstOrNull?.title ?? '',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xff36B3F4)),
                        ),
                      ),
                      Positioned.fill(
                        child: MarqueeWidget(
                          count: controller.loops.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.competitionDetail, arguments: controller.loops[index].id);
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Text(
                                  controller.loops[index].title ?? '',
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xff36B3F4)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          DecoratedSliver(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              boxShadow: [
                BoxShadow(
                  color: '#b9d0e5'.hexColor.withOpacity(0.64),
                  blurRadius: 2.r,
                  offset: Offset(0, -1.w),
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 1.r,
                  blurRadius: 2.r,
                  offset: Offset(0, 1.w),
                ),
                BoxShadow(
                  color: '#bfd2e2'.hexColor.withOpacity(0.81),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.w),
                ),
                BoxShadow(
                  color: '#f8fbff'.hexColor,
                ),
              ],
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => NewsItem(
                  item: controller.articles[index],
                ),
                childCount: controller.articles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(HomeChildController controller) {
    if (controller.articles.isEmpty) return const SizedBox();
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoading,
      child: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return VideoItem(
              item: controller.articles[0],
            );
          }
          return GridView.builder(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.w,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.articles.skip(1).toList().length,
            itemBuilder: (context, index) {
              return VideoItem(
                item: controller.articles.skip(1).toList()[index],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookView(HomeChildController controller) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoading,
      child: ListView.builder(
        controller: controller.listController,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                if (controller.bookSuggests.isNotEmpty)
                  LinearCard(
                      margin: EdgeInsets.all(16.w).copyWith(bottom: 0),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '热门推荐',
                                  style: TextStyle(color: const Color(0xff2C2C2C), fontSize: 16.w),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.loadBookSuggest();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '换一换',
                                        style: TextStyle(color: const Color(0xff2A2C31), fontSize: 12.w),
                                      ),
                                      SizedBox(width: 5.w),
                                      Image.asset(
                                        'assets/images/refresh.png',
                                        width: 12.w,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8.w),
                            LayoutBuilder(builder: (context, constraints) {
                              final maxWidth = constraints.maxWidth;
                              final itemWidth = (maxWidth - 16.w * 3) / 4;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ...List.generate(controller.bookSuggests.length, (i) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (controller.bookSuggests[i].id != null) {
                                          Get.toNamed(Routes.bookDetail, arguments: controller.bookSuggests[i].id!);
                                        }
                                      },
                                      child: SizedBox(
                                        width: itemWidth,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 3 / 4,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(4.w)),
                                                child: CachedNetworkImage(
                                                  imageUrl: controller.bookSuggests[i].cover ?? '',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                                  errorWidget: (context, url, error) =>
                                                      Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8.w),
                                            Text(
                                              controller.bookSuggests[i].title ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 14.w),
                                            ),
                                            SizedBox(
                                              height: 10.w,
                                            ),
                                            Text(
                                              controller.bookSuggests[i].author ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: const Color(0xff909FBB), fontSize: 12.w),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                ],
                              );
                            })
                          ],
                        ),
                      )),
                BookItem(article: controller.articles[index])
              ],
            );
          }
          return BookItem(article: controller.articles[index]);
        },
        itemCount: controller.articles.length,
      ),
    );
  }

  Widget _buildCourseView(HomeChildController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40.w,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16.w),
                ...List.generate(
                  controller.categories.length,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        controller.categorySel = index;
                        controller.categoryId = controller.categories[index].id;
                        controller.pageNum = 1;
                        controller.update();
                        controller.reqListData();
                        controller.listController.animateTo(
                          0.0, // 滚动到顶部的偏移量
                          duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
                          curve: Curves.ease, // 滚动动画的曲线
                        );
                      },
                      child: Container(
                        height: 30.w,
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.w),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  controller.categorySel == index ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: controller.categorySel == index
                                ? const [
                                    Color(0xFF75BFFF),
                                    Color(0xFF48AAFF),
                                    Color(0xFF479DFF),
                                    Color(0xFF3B91F1),
                                  ]
                                : const [
                                    Color(0xFFF5F8FF),
                                    Color(0xFFECF3FF),
                                  ],
                          ),
                        ),
                        child: Text(
                          controller.categories[index].name ?? '',
                          style: TextStyle(
                            color: controller.categorySel == index ? Colors.white : const Color(0xff95A3C4),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoading,
            child: ListView.builder(
              controller: controller.listController,
              itemBuilder: (c, index) {
                CourseBean bean = controller.courses[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 11.w,
                          margin: EdgeInsets.only(right: 5.w, left: 18.w),
                          decoration:
                              BoxDecoration(color: const Color(0xff249CFC), borderRadius: BorderRadius.circular(1.5.w)),
                        ),
                        Text(
                          bean.heading!,
                          style: TextStyle(color: const Color(0xff424242), fontSize: 14.w),
                        )
                      ],
                    ),
                    CourseItem(article: bean)
                  ],
                );
              },
              itemCount: controller.courses.length,
            ),
          ),
        ),
      ],
    );
  }

  void jumpPage(BannerBean bean) {
    if (bean.jumpValue == null) return;
    if (bean.jumpType == 'url') {
      if (bean.jumpValue?.isNotEmpty == true) {
        launchUrlString(bean.jumpValue!, mode: LaunchMode.externalApplication);
      }
      return;
    }
    var id = int.tryParse(bean.jumpValue!);
    if (id == null) return;
    if (bean.jumpType == 'book') {
      Get.toNamed(Routes.bookDetail, arguments: id);
    } else if (bean.jumpType == 'article') {
      Get.toNamed(Routes.articleDetail, arguments: id);
    } else if (bean.jumpType == 'video' || bean.jumpType == 'videoList') {
      Get.toNamed(Routes.videoDetail, arguments: {'id': id});
    } else if (bean.jumpType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
    }
  }
}
