import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/banner.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/item_article.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/item_competition.dart';
import 'package:holdem/widget/item_course.dart';
import 'package:holdem/widget/item_video.dart';
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

class SearchChildViewState extends State<SearchChildView> {
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
    pageNum = 1;
    reqListData();
  }

  void _onLoading() async {
    pageNum++;
    reqListData();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case SearchType.news:
        return SmartRefresher(
          enablePullDown: false,
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
      case SearchType.video:
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: isLoaded
              ? articles.isNotEmpty
                  ? GridView.builder(
                      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.w,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (c, i) => VideoItem(article: articles[i]),
                    )
                  : const NoDataView()
              : const SizedBox(),
        );
      case SearchType.book:
        return SmartRefresher(
          enablePullDown: false,
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
      case SearchType.course:
        return LinearCard(
          padding: EdgeInsets.only(bottom: 2.w),
          margin: EdgeInsets.only(top: 10.w, left: 18.w, right: 18.w, bottom: 10.w),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffF8FBFF),
              borderRadius: BorderRadius.all(Radius.circular(13.w)),
            ),
            child: SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: isLoaded
                  ? courses.isNotEmpty
                      ? ListView.builder(
                          controller: _listController,
                          itemBuilder: (c, i) => GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.articleDetail, arguments: courses[i].targetId ?? 0);
                            },
                            child: Container(
                              height: 48.px,
                              padding: EdgeInsets.symmetric(horizontal: 20.px),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: i < courses.length - 1 ? const Color(0xffe6e6e6) : Colors.transparent),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      courses[i].title ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/arrow.png',
                                    width: 6.px,
                                    height: 10.px,
                                  )
                                ],
                              ),
                            ),
                          ),
                          itemCount: courses.length,
                        )
                      : const NoDataView()
                  : const SizedBox(),
            ),
          ),
        );
      case SearchType.user:
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: isLoaded
              ? userItems.isNotEmpty
                  ? ListView.builder(
                      controller: _listController,
                      itemBuilder: (context, index) => Container(
                        height: 58.w,
                        margin: EdgeInsets.symmetric(horizontal: 18.w),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: const Color(0xffE6E6E6), width: 1.w))),
                        child: Row(children: [
                          BorderAvatar(avatar: userItems[index].avatar ?? ''),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            userItems[index].nickname!.isNotEmpty ? userItems[index].nickname! : '',
                            style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 12.w),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              UserStore.of.checkLogin(() {
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
                                    height: 28.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffd8d8d8),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                                    height: 28.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff249cfc),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
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
      case SearchType.tag:
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: isLoaded
              ? competitionItems.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      controller: _listController,
                      itemBuilder: (context, index) => CompetitionItem(item: competitionItems[index]),
                      itemCount: competitionItems.length,
                    )
                  : const NoDataView()
              : const SizedBox(),
        );
      case SearchType.competition:
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: isLoaded
              ? competitionItems.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      controller: _listController,
                      itemBuilder: (context, index) => CompetitionItem(item: competitionItems[index]),
                      itemCount: competitionItems.length,
                    )
                  : const NoDataView()
              : const SizedBox(),
        );
    }
  }

  jumpPage(BannerBean bean) {
    var id = int.parse(bean.jumpValue!);
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

  @override
  bool get wantKeepAlive => true;
}
