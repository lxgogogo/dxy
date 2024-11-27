import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/page/comment/item_comment.dart';
import 'package:holdem/page/feed_detail/feed_detail_screen.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/page/index/competition_calendar_page.dart';
import 'package:holdem/page/index/item_article.dart';
import 'package:holdem/page/index/item_book.dart';
import 'package:holdem/page/index/item_video.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/page/video_detail/video_detail_screen.dart';
import 'package:holdem/page/video_list/video_list_screen.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchChildView extends StatefulWidget {
  final SearchType type;
  final TextEditingController controller;

  const SearchChildView({super.key, required this.type, required this.controller});

  @override
  State<SearchChildView> createState() => SearchChildViewState();
}

class SearchChildViewState extends State<SearchChildView> with AutomaticKeepAliveClientMixin {
  List<ArticleBean> articles = [];
  List<CollectBean> courses = [];
  List<UserProfile> userItems = [];
  List<CompetitionBean> competitionItems = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;

  final ScrollController _listController = ScrollController();

  bool isLoaded = false;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    eventSubscription = EventBusUtil.of.on<EventRefreshSearchResult>().listen((event) {
      reqListData(showLoading: true);
    });
    reqListData();
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  reqListData({bool showLoading = false}) {
    if (showLoading) {
      isLoaded = false;
    }
    final keyword = widget.controller.text;
    Map<String, Object> params = {
      'pageNum': pageNum,
      'pageSize': 10,
      'filters': {
        'categoryAlias': widget.type.categoryAlias,
        'q': keyword.length > 200 ? keyword.substring(0, 200) : keyword,
      }
    };
    if (widget.type == SearchType.course) {
      NetRequest().courseList(params, (data) {
        isLoaded = true;
        List<CollectBean> dataList = [];
        for (var item in data['list']) {
          dataList.add(CollectBean.fromJson(item));
        }
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
    } else if (widget.type == SearchType.user) {
      NetRequest().userSearch(pageNum, 10, widget.controller.text, (data) {
        isLoaded = true;
        UserDataList userDataList = UserDataList.fromJson(data);
        if (mounted) {
          setState(() {
            if (pageNum == 1) {
              userItems = userDataList.list ?? [];
            } else {
              userItems.addAll(userDataList.list ?? []);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    } else if (widget.type == SearchType.competition) {
      NetRequest().indexList(params, (data) {
        isLoaded = true;
        final dataList = List<CompetitionBean>.from(
          (data?['list'] as List? ?? []).map(
            (e) => CompetitionBean.fromJson(e),
          ),
        );
        if (mounted) {
          setState(() {
            if (pageNum == 1) {
              competitionItems = dataList;
            } else {
              competitionItems.addAll(dataList);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    } else {
      NetRequest().indexList(params, (data) {
        isLoaded = true;
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
    super.build(context);
    if (widget.type == SearchType.news) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? articles.isNotEmpty
                ? ListView.builder(
                    controller: _listController,
                    itemBuilder: (c, i) => ArticleItem(article: articles[i]),
                    itemCount: articles.length,
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    } else if (widget.type == SearchType.video) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? articles.isNotEmpty
                ? GridView.builder(
                    padding: EdgeInsets.only(left: 12.px, right: 12.px, top: 12.px),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.px,
                      mainAxisSpacing: 8.px,
                    ),
                    itemCount: articles.length,
                    itemBuilder: (c, i) => VideoItem(article: articles[i]),
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    } else if (widget.type == SearchType.book) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? articles.isNotEmpty
                ? ListView.builder(
                    controller: _listController,
                    itemBuilder: (c, i) => BookItem(article: articles[i]),
                    itemCount: articles.length,
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    } else if (widget.type == SearchType.course) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? courses.isNotEmpty
                ? ListView.builder(
                    controller: _listController,
                    itemBuilder: (c, i) => courseItem(i),
                    itemCount: courses.length,
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    } else if (widget.type == SearchType.user) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? userItems.isNotEmpty
                ? ListView.builder(
                    controller: _listController,
                    itemBuilder: (context, index) => Container(
                      height: 58.px,
                      margin: EdgeInsets.symmetric(horizontal: 18.px),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: const Color(0xffE6E6E6), width: 1.px))),
                      child: Row(children: [
                        BorderAvatar(avatar: userItems[index].avatar ?? ''),
                        SizedBox(
                          width: 10.px,
                        ),
                        Text(
                          userItems[index].nickname!.isNotEmpty ? userItems[index].nickname! : '',
                          style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 12.px),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Global().checkLogin(() {
                              if (userItems[index].id == null) return;
                              final followed = userItems[index].followed ?? false;
                              NetRequest().followerToggle(userItems[index].id!, !followed, (data) {
                                if (mounted) {
                                  userItems[index].followed = !followed;
                                  setState(() {});
                                }
                              });
                            });
                          },
                          child: userItems[index].followed == true
                              ? Container(
                                  height: 28.px,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffd8d8d8),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.px),
                                  child: const Text(
                                    '已关注',
                                    style: TextStyle(
                                      color: Color(0xff95a3c4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 28.px,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff249cfc),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.px),
                                  child: const Text(
                                    '+关注',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ),
                      ]),
                    ),
                    itemCount: userItems.length,
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    } else if (widget.type == SearchType.competition) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: isLoaded
            ? competitionItems.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14.px),
                    controller: _listController,
                    itemBuilder: (context, index) => CompetitionItem(item: competitionItems[index]),
                    itemCount: competitionItems.length,
                  )
                : const NoDataView()
            : const SizedBox(),
      );
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        controller: _listController,
        itemBuilder: (c, i) => const SizedBox(),
        itemCount: articles.length,
      ),
    );
  }

  Widget courseItem(int index) {
    return LinearCard(
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
              ...List.generate(courses.length, (i) {
                CollectBean collectBean = courses[i];
                return GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.articleDetail, arguments: collectBean.targetId ?? 0);
                    },
                    child: Container(
                      height: 48.px,
                      padding: EdgeInsets.symmetric(horizontal: 20.px),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: i < courses.length - 1 ? const Color(0xffe6e6e6) : Colors.transparent))),
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
    );
  }

  jumpPage(BannerBean bean) {
    var id = int.parse(bean.jumpValue!);
    if (bean.jumpType == 'book') {
      Get.toNamed(Routes.bookDetail, arguments: id);
    } else if (bean.jumpType == 'article') {
      Get.toNamed(Routes.articleDetail, arguments: id);
    } else if (bean.jumpType == 'videoList') {
      Get.toNamed(Routes.videoList, arguments: id);
    } else if (bean.jumpType == 'video') {
      Get.toNamed(Routes.videoDetail, arguments: id);
    } else if (bean.jumpType == 'thread') {
      Get.toNamed(Routes.feedDetail, arguments: id);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
