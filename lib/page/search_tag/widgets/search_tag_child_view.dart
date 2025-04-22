import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_list.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/search_tag/search_tag_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/item_news.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_feed.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/track_utils.dart';
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
        ? ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
            itemBuilder: (_, int index) => GestureDetector(
              onTap: TrackUtils.trackedTap(
                onTap: () {
                  Get.toNamed(Routes.articleDetail, arguments: controller.courses[index].targetId ?? 0);
                },
                userLogType: '112003',
                params: controller.courses[index].targetId,
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 16.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index < controller.courses.length - 1
                          ? '#000000'.hexColor.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Text(
                  controller.courses[index].title ?? '',
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 16.sp,
                  ),
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            separatorBuilder: (_, int index) => SizedBox(height: 16.w),
            itemCount: controller.courses.length,
          )
        : const Center(child: NoDataView());
  }

  Widget _buildBookView(SearchTagChildController controller) {
    if (controller.articles.isEmpty) {
      return const Center(
        child: NoDataView(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.w),
      itemCount: (controller.articles.length / 2).ceil(),
      itemBuilder: (BuildContext context, int index) {
        final int firstIndex = index * 2;
        final int secondIndex = firstIndex + 1;
        final bool hasSecond = secondIndex < controller.articles.length;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final itemWidth = (constraints.maxWidth - 12.w) / 2;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ThreeDBookItem(
                      onTap: () => TrackUtils.trackEvent(
                        userLogType: '112002',
                        params: controller.articles[firstIndex].id,
                      ),
                      item: controller.articles[firstIndex],
                      itemWidth: itemWidth,
                    ),
                  ),
                  if (hasSecond) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ThreeDBookItem(
                        onTap: () => TrackUtils.trackEvent(
                          userLogType: '112002',
                          params: controller.articles[secondIndex].id,
                        ),
                        item: controller.articles[secondIndex],
                        itemWidth: itemWidth,
                      ),
                    ),
                  ] else
                    const Expanded(child: SizedBox()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoView(SearchTagChildController controller) {
    if (controller.articles.isEmpty) {
      return const Center(
        child: NoDataView(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.w),
      itemCount: (controller.articles.length / 2).ceil(),
      itemBuilder: (BuildContext context, int index) {
        final int firstIndex = index * 2;
        final int secondIndex = firstIndex + 1;
        final bool hasSecond = secondIndex < controller.articles.length;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: VideoItem(
                  onTap: () => TrackUtils.trackEvent(
                    userLogType: '112001',
                    params: controller.articles[firstIndex].id,
                  ),
                  item: controller.articles[firstIndex],
                ),
              ),
              if (hasSecond) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: VideoItem(
                    onTap: () => TrackUtils.trackEvent(
                      userLogType: '112001',
                      params: controller.articles[secondIndex].id,
                    ),
                    item: controller.articles[secondIndex],
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewsView(SearchTagChildController controller) {
    return controller.articles.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
            itemBuilder: (c, i) => NewsItem(item: controller.articles[i]),
            itemCount: controller.articles.length,
          )
        : const NoDataView();
  }

  Widget _buildFeedView(SearchTagChildController controller) {
    return controller.feeds.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 24.w),
            itemBuilder: (c, i) => FeedItem(
              onTap: () => TrackUtils.trackEvent(
                userLogType: '112004',
                params: controller.feeds[i].id,
              ),
              controller.feeds[i],
            ),
            itemCount: controller.feeds.length,
          )
        : const Center(child: NoDataView());
  }
}
