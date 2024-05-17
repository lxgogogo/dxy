import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/index_category.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/holdem_btn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  List<IndexCategory> categorys = [];
  int categorySel = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int pageNum = 1;

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

    NetRequest().indexList({
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {
        'categoryAlias': widget.type //'article'
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

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    if (widget.type == 'course') {
      return Column(
        children: [
          Container(
            height: 40.px,
            // color: Colors.orange,
            child: Row(
              children: [
                ...List<Widget>.generate(categorys.length, (index) {
                  return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.px),
                      child: index != categorySel
                          ? HoldemNormalBtn(
                              child: Text(
                                categorys[index].name ?? '',
                                style: TextStyle(color: Color(0xff56748F)),
                              ),
                              onTap: () {
                                setState(() {
                                  categorySel = index;
                                });
                                reqListData();
                              })
                          : HoldemHighlightBtn(
                              child: Text(
                                categorys[index].name ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  pageNum = 1;
                                });
                                reqListData();
                              }));
                })
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
          ),
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
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.px),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8.px,
              mainAxisSpacing: 8.px,
            ),
            itemBuilder: (c, i) => contentItem(i),
            itemCount: articles.length,
          ));
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => contentItem(i),
        // itemExtent: 160.0,
        itemCount: articles.length,
      ),
    );
  }

  contentItem(int index) {
    if (widget.type == 'book') {
      return BookItem(
        article: articles[index],
      );
    }
    if (widget.type == 'news' && index == 0) {
      return Column(
        children: [
          if (banners.length > 0)
            Container(
              margin: EdgeInsets.only(left: 20.px, right: 20.px,top: 10.px),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.px),
              ),
              height: 160.px,
              child: Swiper(
                itemCount: banners.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.network(
                    banners[index].img ?? '',
                    fit: BoxFit.cover,
                  );
                },
                pagination: SwiperPagination(),
                autoplay: true,
              ),
            ),
          VideoItem(
            article: articles[index],
          )
        ],
      );
    }
    return VideoItem(
      article: articles[index],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
