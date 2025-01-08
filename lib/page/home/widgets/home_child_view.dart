import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/competition_loop.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/home/widgets/home_marquee_widget.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/item_article.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_course.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../model/board_list.dart';

class HomeChildView extends StatefulWidget {
  final String type;

  const HomeChildView({super.key, required this.type});

  @override
  State<HomeChildView> createState() => _HomeChildViewState();
}

class _HomeChildViewState extends State<HomeChildView> with AutomaticKeepAliveClientMixin {
  List<ArticleBean> articles = [];
  List<BannerBean> banners = [];
  List<ArticleBean> bookSuggests = [];
  List<IndexCategory> categories = [];
  int? categoryId;
  List<CourseBean> courses = [];
  List<CompetionLoopBean> loops = [];
  int categorySel = 0;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;

  final ScrollController _listController = ScrollController();

  StreamSubscription? eventSubscription;
  StreamSubscription? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> events,
    ) {
      if (!events.contains(ConnectivityResult.none)) {
        _onRefresh();
      }
    });
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      _onRefresh();
    });
    _onRefresh();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    eventSubscription?.cancel();
    super.dispose();
  }

  reqOtherData() {
    if (widget.type == 'news') {
      NetRequest().indexBanner({
        'pos': 'index.banner',
        'type': '1',
      }, (data) {
        List<BannerBean> bannerList = List<BannerBean>.from(data.map((banner) => BannerBean.fromJson(banner)));
        if (mounted) {
          setState(() {
            banners = bannerList;
          });
        }
      });
      NetRequest().competitionLoop({}, (data) {
        List<CompetionLoopBean> loopList =
            List<CompetionLoopBean>.from(data.map((loop) => CompetionLoopBean.fromJson(loop)));
        if (mounted) {
          loops = loopList;
          setState(() {});
        }
      });
    } else if (widget.type == 'book') {
      getBookSuggest();
    } else if (widget.type == 'course') {
      NetRequest().courseCategory({"parentAlias": "course", "parentId": 1}, (data) {
        List<IndexCategory> categoryList =
            List<IndexCategory>.from(data.map((category) => IndexCategory.fromJson(category)));
        categoryList.insert(0, IndexCategory(name: '全部'));
        if (mounted) {
          setState(() {
            categories = categoryList;
          });
        }
      });
    }
  }

  reqListData() {
    if (widget.type == 'course') {
      NetRequest().courseList({
        'pageNum': pageNum,
        'pageSize': 10,
        'filters': {
          'categoryAlias': 'course',
          if (categoryId != null) 'categoryId': categoryId,
        }
      }, (data) {
        List<CourseBean> dataList = List<CourseBean>.from(data['list'].map((course) => CourseBean.fromJson(course)));
        if (mounted) {
          final pager = Paper.fromJson(data['pager']);
          final total = pager.total ?? 0;
          if (pageNum == 1) {
            courses = dataList;
            _refreshController.refreshCompleted();
            if (courses.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.resetNoData();
            }
          } else {
            courses.addAll(dataList);
            if (courses.length >= total) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
          setState(() {});
        }
      });
    } else {
      NetRequest().indexList({
        'pageNum': pageNum,
        'pageSize': 10,
        'filters': {
          'categoryAlias': widget.type, //'article'
        }
      }, (data) {
        List<ArticleBean> dataList =
            List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));

        if (mounted) {
          setState(() {
            if (pageNum == 1) {
              articles = dataList;
            } else {
              articles.addAll(dataList);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    }
  }

  void getBookSuggest() {
    NetRequest().bookRecommend({"pageSize": 4}, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(data.map((article) => ArticleBean.fromJson(article)));

      if (mounted) {
        setState(() {
          bookSuggests = dataList;
        });
      }
    });
  }

  void _onRefresh() async {
    pageNum = 1;
    reqListData();
    reqOtherData();
  }

  void _onLoading() async {
    pageNum++;
    reqListData();
    reqOtherData();
  }

  Widget courseItem(int index) {
    CourseBean bean = courses[index];
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 11.w,
              margin: EdgeInsets.only(right: 5.w, left: 18.w),
              decoration: BoxDecoration(color: const Color(0xff249CFC), borderRadius: BorderRadius.circular(1.5.w)),
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.type == 'course') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [buildHomeTabs(), Expanded(child: content())],
      );
    }
    return content();
  }

  Widget buildHomeTabs() {
    return SizedBox(
        height: 40.w,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16.w,
              ),
              ...List.generate(categories.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      categorySel = index;
                      categoryId = categories[index].id;
                      pageNum = 1;
                    });
                    reqListData();
                    _scrollToTop();
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
                            color: categorySel == index ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: categorySel == index
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
                        )),
                    child: Text(
                      categories[index].name ?? '',
                      style: TextStyle(
                          color: categorySel == index ? Colors.white : const Color(0xff95A3C4), fontSize: 14.w),
                    ),
                  ),
                );
              }),
            ],
          ),
        ));
  }

  Widget content() {
    if (widget.type == 'book') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: _listController,
            itemBuilder: (c, i) => contentItem(i),
            itemCount: articles.length,
          ));
    } else if (widget.type == 'video') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: articles.isEmpty ? Container() : videoList());
    } else if (widget.type == 'course') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: _listController,
            itemBuilder: (c, i) => courseItem(i),
            itemCount: courses.length,
          ));
    }
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          controller: _listController,
          itemBuilder: (c, i) => contentItem(i),
          // itemExtent: 160.0,
          itemCount: articles.length,
        ));
  }

  videoList() {
    List<ArticleBean> videos = articles.skip(1).toList();
    return ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return VideoItem(
              article: articles[0],
              isBanner: true,
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
            physics: NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (contxt, indx) {
              return VideoItem(
                article: videos[indx],
                isBanner: false,
              );
            },
          );
        });
  }

  jumpPage(BannerBean bean) {
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
      Get.toNamed(Routes.videoDetail, arguments: id);
    } else if (bean.jumpType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
    }
  }

  Widget contentItem(int index) {
    if (widget.type == 'news') {
      if (index == 0) {
        return buildNewsTopArea(index);
      }
      return ArticleItem(article: articles[index]);
    } else if (widget.type == 'video') {
      return VideoItem(article: articles[index]);
    }
    if (widget.type == 'book') {
      if (index == 0) {
        return buildBookTopArea(index);
      }
      return BookItem(article: articles[index]);
    }
    return const SizedBox();
  }

  Column buildNewsTopArea(int index) {
    return Column(
      children: [
        if (banners.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxWidth / (1200 / 500) + 20.w,
                  child: Swiper(
                    itemCount: banners.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          jumpPage(banners[index]);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20.w),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: banners[index].imgMobile ?? '',
                            placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                            errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
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
                                    color:
                                        config.activeIndex == index ? const Color(0xff008EFF) : const Color(0xffADCCE8),
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
        if (loops.isNotEmpty)
          GestureDetector(
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
                      loops[index].title ?? '',
                      style: TextStyle(fontSize: 12.w, color: const Color(0xff36B3F4)),
                    ),
                  ),
                  Positioned.fill(
                    child: MarqueeWidget(
                      count: loops.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.competitionDetail, arguments: loops[index].id);
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Text(
                              loops[index].title ?? '',
                              style: TextStyle(fontSize: 12.w, color: const Color(0xff36B3F4)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // child: PageView.builder(
              //   controller: _controller,
              //   itemCount: loops.length,
              //   scrollDirection: Axis.vertical,
              //   itemBuilder: (context, index) {
              //     return GestureDetector(
              //       onTap: () {
              //         Get.to(CompetitionDetailPage(id: loops[index].id));
              //       },
              //       behavior: HitTestBehavior.translucent,
              //       child: Center(
              //         child: Text(
              //           loops[index].title ?? '',
              //           style: TextStyle(fontSize: 12.w, color: const Color(0xff36B3F4)),
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ),
          ),
        ArticleItem(article: articles[index]),
      ],
    );
  }

  Widget buildBookTopArea(int index) {
    return Column(
      children: [
        if (bookSuggests.isNotEmpty)
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
                            getBookSuggest();
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
                          ...List.generate(bookSuggests.length, (i) {
                            return GestureDetector(
                              onTap: () {
                                if (bookSuggests[i].id != null) {
                                  Get.toNamed(Routes.bookDetail, arguments: bookSuggests[i].id!);
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
                                          imageUrl: bookSuggests[i].cover ?? '',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                          errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.w),
                                    Text(
                                      bookSuggests[i].title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 14.w),
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Text(
                                      bookSuggests[i].author ?? '',
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
        BookItem(article: articles[index])
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _scrollToTop() {
    // 滚动到顶部的逻辑
    _listController.animateTo(
      0.0, // 滚动到顶部的偏移量
      duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
      curve: Curves.ease, // 滚动动画的曲线
    );
  }
}
