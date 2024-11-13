import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/competition_loop.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/competition_detail_page.dart';
import 'package:holdem/page/index/item_article.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/page/index/competition_calendar_page.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    reqListData();
    NetRequest().competitionLoop({}, (data) {
      List<CompetionLoopBean> loopList =
          List<CompetionLoopBean>.from(data.map((loop) => CompetionLoopBean.fromJson(loop)));
      if (mounted) {
        setState(() {
          loops = loopList;
        });
      }

      Timer.periodic(Duration(seconds: 3), (timer) {
        _currentPage++;
        if (_currentPage >= loopList.length) {
          _currentPage = 0;
        }
        if (mounted && _controller.hasClients) {
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  reqListData() {
    if (widget.type == 'news') {
      NetRequest().indexBanner({
        'pos': 'index.banner',
      }, (data) {
        List<BannerBean> bannerList = List<BannerBean>.from(data.map((banner) => BannerBean.fromJson(banner)));
        if (mounted) {
          setState(() {
            banners = bannerList;
          });
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
          setState(() {
            if (pageNum == 1) {
              courses = dataList;
            } else {
              courses.addAll(dataList);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
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
    setState(() {
      pageNum = 1;
    });
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  Widget courseItem(int index) {
    CourseBean bean = courses[index];
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 3.px,
              height: 11.px,
              margin: EdgeInsets.only(right: 5.px, left: 18.px),
              decoration: BoxDecoration(color: const Color(0xff249CFC), borderRadius: BorderRadius.circular(1.5.px)),
            ),
            Text(
              bean.heading!,
              style: TextStyle(color: const Color(0xff424242), fontSize: 14.px),
            )
          ],
        ),
        LinearCard(
          padding: EdgeInsets.only(bottom: 2.px),
          margin: EdgeInsets.only(top: 10.px, left: 18.px, right: 18.px, bottom: 10.px),
          child: Container(
              // padding: EdgeInsets.only(left: 20.px,right: 12.px,top:5.px,bottom: 5.px),
              decoration: BoxDecoration(
                color: const Color(0xffF8FBFF),
                borderRadius: BorderRadius.all(Radius.circular(13.px)),
              ),
              child: Column(
                children: [
                  ...List.generate(bean.sublist!.length, (i) {
                    CollectBean collectBean = bean.sublist![i];
                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed("/article_detail?id=${collectBean.targetId ?? 0}",
                              arguments: collectBean.targetId ?? 0);
                        },
                        child: Container(
                          height: 48.px,
                          padding: EdgeInsets.symmetric(horizontal: 20.px),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: i < bean.sublist!.length - 1
                                          ? const Color(0xffe6e6e6)
                                          : Colors.transparent))),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                collectBean.title!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                              Image.asset(
                                'assets/images/arrow.png',
                                width: 6.px,
                                height: 10.px,
                              )
                            ],
                          ),
                        ));
                  }),
                ],
              )),
        )
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
        height: 40.px,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16.px,
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
                    height: 30.px,
                    margin: EdgeInsets.only(right: 10.px),
                    padding: EdgeInsets.symmetric(horizontal: 15.px),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.px),
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
                          color: categorySel == index ? Colors.white : const Color(0xff95A3C4), fontSize: 14.px),
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
          header: const WaterDropHeader(
            waterDropColor: Color(0xff008EFF),
          ),
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
          header: const WaterDropHeader(
            waterDropColor: Color(0xff008EFF),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: articles.isEmpty ? Container() : videoList());
    } else if (widget.type == 'course') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(
            waterDropColor: Color(0xff008EFF),
          ),
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
        header: const WaterDropHeader(
          waterDropColor: Color(0xff008EFF),
        ),
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
            padding: EdgeInsets.only(left: 12.px, right: 12.px, top: 12.px),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.px,
              mainAxisSpacing: 8.px,
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
    var id = int.parse(bean.jumpValue!);
    if (bean.jumpType == 'book') {
      Navigator.of(context).pushNamed("/book_detail?id=${id}", arguments: id);
      // Get.to(BookDetailPage(id: id));
    } else if (bean.jumpType == 'article') {
      Navigator.of(context).pushNamed("/article_detail?id=${id}", arguments: id);
      // Get.to(ArticleDetailPage(id: id));
    } else if (bean.jumpType == 'videoList') {
      Navigator.of(context).pushNamed("/video_list?id=${id}", arguments: id);
      // Get.to(VideoListPage(id: id));
    } else if (bean.jumpType == 'video') {
      Navigator.of(context).pushNamed("/video_detail?id=${id}", arguments: id);
      // Get.to(VideoDetailPage(id: id));
    } else if (bean.jumpType == 'thread') {
      Get.to(PostDetailPage(postId: id));
    }
  }

  Widget contentItem(int index) {
    if (widget.type == 'news') {
      if (index == 0) {
        return buildNewsTopArea(index);
      }
      return ArticleItem(
        article: articles[index],
      );
    } else if (widget.type == 'video') {
      return VideoItem(
        article: articles[index],
        isBanner: false,
      );
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
          Container(
            margin: EdgeInsets.only(left: 16.px, right: 16.px, top: 10.px),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.px),
            ),
            height: 140.px + 20,
            child: Swiper(
              itemCount: banners.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.px),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      jumpPage(banners[index]);
                    },
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: banners[index].img ?? '',
                      placeholder: (context, url) => Image.asset('assets/images/image_loading_def.png'),
                      errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                    ),
                  ),
                );
              },
              pagination: SwiperPagination(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 0.px),
                builder: SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          config.itemCount,
                          (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: config.activeIndex == index ? 20.0 : 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    color:
                                        config.activeIndex == index ? const Color(0xff008EFF) : const Color(0xffADCCE8),
                                    borderRadius: config.activeIndex == index
                                        ? BorderRadius.circular(3.0)
                                        : BorderRadius.circular(3.0),
                                  ),
                                ),
                              )));
                }),
              ),
              autoplay: true,
            ),
          ),
        if (loops.isNotEmpty)
          GestureDetector(
            onTap: () {
              Get.to(const CompetitionCalendarPage());
            },
            child: Container(
              width: 361.px,
              height: 85.px,
              padding: EdgeInsets.only(left: 60.px, right: 60.px, top: 20.px, bottom: 10.px),
              decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/game.png'), fit: BoxFit.fill)),
              child: PageView.builder(
                controller: _controller,
                itemCount: loops.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(CompetitionDetailPage(id: loops[index].id));
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Center(
                      child: Text(
                        loops[index].title ?? '',
                        style: TextStyle(fontSize: 12.px, color: const Color(0xff36B3F4)),
                      ),
                    ),
                  );
                },
              ),
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
              margin: EdgeInsets.all(16.px).copyWith(bottom: 0),
              child: Container(
                padding: EdgeInsets.all(16.px),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '热门推荐',
                          style: TextStyle(color: const Color(0xff2C2C2C), fontSize: 16.px),
                        ),
                        GestureDetector(
                          onTap: () {
                            getBookSuggest();
                          },
                          child: Row(
                            children: [
                              Text(
                                '换一换',
                                style: TextStyle(color: const Color(0xff2A2C31), fontSize: 12.px),
                              ),
                              SizedBox(width: 5.px),
                              Image.asset(
                                'assets/images/refresh.png',
                                width: 12.px,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8.px),
                    LayoutBuilder(builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final itemWidth = (maxWidth - 16.px * 3) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(bookSuggests.length, (i) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed("/book_detail?id=${bookSuggests[i].id}", arguments: bookSuggests[i].id);
                              },
                              child: SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(4.px)),
                                        child: Image.network(
                                          bookSuggests[i].cover ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.px),
                                    Text(
                                      bookSuggests[i].title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 14.px),
                                    ),
                                    SizedBox(
                                      height: 10.px,
                                    ),
                                    Text(
                                      bookSuggests[i].author ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: const Color(0xff909FBB), fontSize: 12.px),
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

  @override
  void dispose() {
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  void _scrollToTop() {
    // 滚动到顶部的逻辑
    _listController.animateTo(
      0.0, // 滚动到顶部的偏移量
      duration: const Duration(milliseconds: 300), // 滚动动画的持续时间
      curve: Curves.ease, // 滚动动画的曲线
    );
  }
}
