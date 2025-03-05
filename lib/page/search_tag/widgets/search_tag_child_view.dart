import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/search_tag/search_tag_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/item_news.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_feed.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/three_d_book_item.dart';

part 'search_tag_child_controller.dart';

class SearchTagChildView extends GetView<SearchTagChildView> {
  final SearchTagType type;
  final TagModel? tagModel;

  const SearchTagChildView({super.key, required this.type, this.tagModel});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchTagChildController>(
      global: false,
      init: SearchTagChildController(type, tagModel),
      builder: (controller) {
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          controller: controller.refreshController,
          onLoading: controller.onLoading,
          child: controller.isLoaded ? _buildView(controller) : const SizedBox(),
        );
      },
    );
  }

  Widget _buildView(SearchTagChildController controller) {
    switch (type) {
      // case SearchTagType.news:
      //   return _buildNewsView(controller);
      case SearchTagType.video:
        return _buildVideoView(controller);
      case SearchTagType.book:
        return _buildBookView(controller);
      case SearchTagType.course:
        return _buildCourseView(controller);
      case SearchTagType.feed:
        return _buildFeedView(controller);
    }
  }

  Widget _buildCourseView(SearchTagChildController controller) {
    return controller.courses.isNotEmpty
        ? CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
                sliver: DecoratedSliver(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: Rect.fromLTRB(30, 14, 35, 28),
                      image: AssetImage('assets/images/commen_bg.png'),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.articleDetail, arguments: controller.courses[index].targetId ?? 0);
                          },
                          child: Container(
                            height: 48.w,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: index < controller.courses.length - 1
                                        ? const Color(0xffe6e6e6)
                                        : Colors.transparent),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.courses[index].title ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/arrow.png',
                                  width: 6.w,
                                  height: 10.w,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: controller.courses.length,
                    ),
                  ),
                ),
              ),
            ],
          )
        : const NoDataView();
  }


  Widget _buildBookView(SearchTagChildController controller) {
    return controller.articles.isNotEmpty
        ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.w),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final itemWidth = (constraints.maxWidth - 12.w) / 2;
          return Wrap(
            spacing: 12.w,
            runSpacing: 12.w,
            children: controller.articles
                .map(
                  (e) => ThreeDBookItem(
                itemWidth: itemWidth,
                item: e,
              ),
            )
                .toList(),
          );
        },
      ),
    )
        : const NoDataView();
  }

  Widget _buildVideoView(SearchTagChildController controller) {
    return controller.articles.isNotEmpty
        ? GridView.builder(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.w,
            ),
            itemCount: controller.articles.length,
            itemBuilder: (c, i) => VideoItem(item: controller.articles[i]),
          )
        : const NoDataView();
  }

  Widget _buildNewsView(SearchTagChildController controller) {
    return controller.articles.isNotEmpty
        ? ListView.builder(
            itemBuilder: (c, i) => NewsItem(item: controller.articles[i]),
            itemCount: controller.articles.length,
          )
        : const NoDataView();
  }

  Widget _buildFeedView(SearchTagChildController controller) {
    return controller.feeds.isNotEmpty
        ? ListView.builder(
            itemBuilder: (c, i) => FeedItem(controller.feeds[i]),
            itemCount: controller.feeds.length,
          )
        : const NoDataView();
  }
}
