import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/item_article.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/page/index/page_article_detail.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/card.dart';
import 'package:holdem/widget/holdem_btn.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sticky_headers/sticky_headers.dart';

// ignore: must_be_immutable
class IndexTabChildPage extends StatefulWidget {
  String type;

  IndexTabChildPage({super.key, required this.type});

  @override
  State<IndexTabChildPage> createState() => _IndexTabChildPageState();
}

class _IndexTabChildPageState extends State<IndexTabChildPage>
    with AutomaticKeepAliveClientMixin {
  List<ArticleBean> articles = [];
  List<BannerBean> banners = [];
  List<ArticleBean> bookSuggests = [];
  List<IndexCategory> categorys = [];
  List<CourseBean> courses = [];
  int categorySel = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int pageNum = 1;
  int parentId = 1;

  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    reqListData();
  }

  reqListData() {
    if (widget.type == 'news') {
      NetRequest().indexBanner({
        'pos': 'index.banner',
      }, (data) {
        List<BannerBean> bannerList = List<BannerBean>.from(
            data.map((banner) => BannerBean.fromJson(banner)));
        if (mounted) {
          setState(() {
            banners = bannerList;
          });
        }
      });
    } else if (widget.type == 'book') {
      getBookSuggest();
    } else if (widget.type == 'course') {
      NetRequest().courseCategory({"parentAlias": "course", "parentId": 1},
          (data) {
        data.insert(0, {"id": 0, "name": "全部"});
        List<IndexCategory> categoryList = List<IndexCategory>.from(
            data.map((category) => IndexCategory.fromJson(category)));
        if (mounted) {
          setState(() {
            categorys = categoryList;
          });
        }
      });
    }

    if (widget.type == 'course') {
      NetRequest().courseList({
        'pageNum': pageNum,
        'pageSize': 10,
        'filters': {
          'categoryAlias': widget.type == 'course' && parentId != 1
              ? null
              : widget.type, //'article'
          'categoryId': widget.type == 'course' ? parentId : null,
        }
      }, (data) {
        // List<ArticleBean> dataList = List<ArticleBean>.from(
        //     data['list'].map((article) => ArticleBean.fromJson(article)));
        List array = [];
        for (var item in data['list']) {
          for (var collect in item['collects']) {
            array.add({
              "heading": collect['heading'],
              "collects": collect['sublist']
            });
          }
        }

        List<CourseBean> dataList = List<CourseBean>.from(
            array.map((course) => CourseBean.fromJson(course)));

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
          'categoryAlias': widget.type == 'course' && parentId != 1
              ? null
              : widget.type, //'article'
          'categoryId': widget.type == 'course' ? parentId : null,
        }
      }, (data) {
        List<ArticleBean> dataList = List<ArticleBean>.from(
            data['list'].map((article) => ArticleBean.fromJson(article)));

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
      List<ArticleBean> dataList = List<ArticleBean>.from(
          data.map((article) => ArticleBean.fromJson(article)));

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
              decoration: BoxDecoration(
                  color: const Color(0xff249CFC),
                  borderRadius: BorderRadius.circular(1.5.px)),
            ),
            Text(
              bean.heading!,
              style: TextStyle(color: const Color(0xff424242), fontSize: 14.px),
            )
          ],
        ),
        LinearCard(
          padding: EdgeInsets.only(bottom: 2.px),
          margin: EdgeInsets.only(
              top: 10.px, left: 18.px, right: 18.px, bottom: 10.px),
          child: Container(
              // padding: EdgeInsets.only(left: 20.px,right: 12.px,top:5.px,bottom: 5.px),
              decoration: BoxDecoration(
                color: const Color(0xffF8FBFF),
                borderRadius: BorderRadius.all(Radius.circular(13.px)),
              ),
              child: Column(
                children: [
                  ...List.generate(bean.collects!.length, (i) {
                    CollectBean collectBean = bean.collects![i];
                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              "/article_detail?id=${collectBean.targetId ?? 0}",
                              arguments: collectBean.targetId ?? 0);
                        },
                        child: Container(
                          height: 48.px,
                          padding: EdgeInsets.symmetric(horizontal: 20.px),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: i < bean.collects!.length - 1
                                          ? const Color(0xffe6e6e6)
                                          : Colors.transparent))),
                          child: Row(
                            children: [
                              Expanded(child: Text(collectBean.title!,overflow: TextOverflow.ellipsis, 
  maxLines: 1,)),
 
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
    SizeFit.initialize(context);
    if (widget.type == 'course') {
      return Column(
        children: [
          Container(
              height: 40.px,
              // color: Colors.orange,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 6.px,
                    ),

                    ...List.generate(categorys.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            categorySel = index;
                            parentId = categorys[index].id ?? 0;
                            pageNum = 1;
                          });
                          reqListData();
                          _scrollToTop();
                        },
                        child: Container(
                          height: 30.px,
                          margin: EdgeInsets.only(right: 10.px),
                          padding: EdgeInsets.symmetric(horizontal: 15.px),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.px),
                              boxShadow: [
                                BoxShadow(
                                  color: categorySel == index
                                      ? const Color(0xFFC8D4EE)
                                      : const Color(0xFFd6e2f0),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
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
                            categorys[index].name ?? '',
                            style: TextStyle(
                                color: categorySel == index
                                    ? Colors.white
                                    : const Color(0xff95A3C4),
                                fontSize: 14.px),
                          ),
                        ),
                      );
                    }),
                    // ...List<Widget>.generate(categorys.length, (index) {
                    //   return Container(
                    //       padding: EdgeInsets.only(left: 10.px),
                    //       child: index != categorySel
                    //           ? HoldemNormalBtn(
                    //               child: Text(
                    //                 categorys[index].name ?? '',
                    //                 style: TextStyle(
                    //                     color: Color(0xff56748F),
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 14),
                    //               ),
                    //               onTap: () {
                    //                 setState(() {
                    //                   categorySel = index;
                    //                   parentId = categorys[index].id ?? 0;
                    //                   pageNum = 1;
                    //                 });
                    //                 reqListData();
                    //                 _scrollToTop();
                    //               })
                    //           : HoldemHighlightBtn(
                    //               child: Text(
                    //                 categorys[index].name ?? '',
                    //                 style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 14),
                    //               ),
                    //               onTap: () {
                    //                 setState(() {
                    //                   pageNum = 1;
                    //                   parentId = categorys[index].id ?? 0;
                    //                 });
                    //                 reqListData();
                    //               }));
                    // })
                  ],
                ),
                // child: ListView.builder(
                //   scrollDirection: Axis.horizontal,
                //   itemBuilder: (c, i) {
                //     return Container(
                //       padding: EdgeInsets.symmetric(horizontal: 10.px),
                //       child: Text(
                //         categorys[i].name ?? '',
                //         style: TextStyle(color: Colors.red),
                //       ),
                //     );
                //   },
                //   itemCount: categorys.length,
                // ),
              )),
          Expanded(child: content())
        ],
      );
      // return Column(
      //   children: [
      //     Container(
      //       height: 50.px,
      //       child: ListView.builder(
      //         scrollDirection: Axis.horizontal,
      //         itemBuilder: (c, i) {
      //           return Container(
      //             padding: EdgeInsets.symmetric(horizontal: 10.px),
      //             child: Text(categorys[i].name ?? '',style: TextStyle(color: Colors.red),),
      //           );
      //         },
      //         itemCount: categorys.length,
      //       ),
      //     ),
      //     content()
      //   ],
      // );
    }
    return content();
  }

  Widget content() {
    if (widget.type == 'book') {
      return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(
            waterDropColor: Color(0xff008EFF),
            complete: Text(
              '加载完成',
              style: TextStyle(color: Color(0xff647A9C)),
            ),
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
      // child: GridView.builder(
      //   padding: EdgeInsets.only(left: 12.px, right: 12.px, top: 12.px),
      //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 2,
      //     childAspectRatio: 0.57,
      //     crossAxisSpacing: 8.px,
      //     mainAxisSpacing: 8.px,
      //   ),
      //   itemBuilder: (c, i) => contentItem(i),
      //   itemCount: articles.length,
      // ));
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
          child: articles.length == 0 ? Container() : videoList());
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
            // itemExtent: 160.0,
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
          /*
          child: GridView.builder(
            padding: EdgeInsets.only(left: 12.px, right: 12.px, top: 12.px),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.57,
              crossAxisSpacing: 8.px,
              mainAxisSpacing: 8.px,
            ),
            itemBuilder: (c, i) => contentItem(i),
            itemCount: articles.length,
          ));
          */
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
      Navigator.of(context)
          .pushNamed("/article_detail?id=${id}", arguments: id);
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

  contentItem(int index) {
    if (widget.type == 'book') {
      if (index == 0) {
        return Column(
          children: [
            if (bookSuggests.length > 0)
              LinearCard(
                margin: EdgeInsets.only(left: 16.px,right: 16.px),
                  child: Container(
                padding: EdgeInsets.all(16.px),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '热门推荐',
                          style: TextStyle(
                              color: const Color(0xff2C2C2C), fontSize: 16.px),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            getBookSuggest();
                          },
                          child: Row(
                            children: [
                              Text(
                                '换一换',
                                style: TextStyle(
                                    color: const Color(0xff2A2C31),
                                    fontSize: 12.px),
                              ),
                              SizedBox(width: 5.px,),
                              Image.asset('assets/images/refresh.png',width: 12.px,)
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12.px,
                    ),
                    Row(
                      children: [
                        ...List.generate(bookSuggests.length, (i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  "/book_detail?id=${bookSuggests[i].id}",
                                  arguments: bookSuggests[i].id);
                            },
                            child: Container(
                              width: 66.px,
                              margin: EdgeInsets.only(right: 13.px),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 8.px),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.px))),
                                    child: Image.network(
                                      bookSuggests[i].cover ?? '',
                                      width: 66.px,
                                      height: 88.px,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40.px,
                                    child: Text(
                                      bookSuggests[i].title ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: const Color(0xff2A2A2A),
                                          fontSize: 14.px),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.px,
                                  ),
                                  Text(
                                    bookSuggests[i].author ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: const Color(0xff909FBB),
                                        fontSize: 12.px),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      ],
                    )
                  ],
                ),
              )),
            BookItem(
              article: articles[index],
            )
          ],
        );
      }
      return BookItem(
        article: articles[index],
      );
    }
    if (widget.type == 'news' && index == 0) {
      return Column(
        children: [
          if (banners.length > 0)
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
                      child: Image.network(
                        banners[index].img ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                pagination: SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 0.px),
                    builder: SwiperCustomPagination(builder:
                        (BuildContext context, SwiperPluginConfig config) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              config.itemCount,
                              (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: config.activeIndex == index
                                          ? 20.0
                                          : 6.0,
                                      height: 6.0,
                                      decoration: BoxDecoration(
                                        color: config.activeIndex == index
                                            ? const Color(0xff008EFF)
                                            : const Color(0xffADCCE8),
                                        borderRadius:
                                            config.activeIndex == index
                                                ? BorderRadius.circular(3.0)
                                                : BorderRadius.circular(3.0),
                                      ),
                                    ),
                                  )));
                    })
                    // builder: const RectSwiperPaginationBuilder(
                    //     color: Color(0xffADCCE8),
                    //     activeColor: Color(0xff008EFF),
                    //     size: Size(10, 10),
                    //     activeSize: Size(20, 10)),

                    ),
                autoplay: true,
              ),
            ),
          ArticleItem(
            article: articles[index],
          )
        ],
      );
    }
    if (widget.type == 'news')
      return ArticleItem(
        article: articles[index],
      );
    return VideoItem(
      article: articles[index],
      isBanner: false,
    );
  }

  @override
  // TODO: implement wantKeepAlive
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
