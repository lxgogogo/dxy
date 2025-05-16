import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/model/course.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/item_news.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/three_d_book_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/track_utils.dart';

part 'search_child_controller.dart';

class SearchChildView extends GetView<SearchChildView> {
  final SearchType type;

  const SearchChildView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchChildController>(
      global: false,
      init: SearchChildController(type),
      builder: (controller) {
        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: controller.items.isNotEmpty == true || !controller.noMore,
          controller: controller.refreshController,
          scrollController: controller.scrollController,
          onLoading: controller.onLoading,
          child: controller.isLoaded ? _buildView(controller) : const SizedBox(),
        );
      },
    );
  }

  Widget _buildView(SearchChildController controller) {
    switch (type) {
      // case SearchType.news:
      //   return _buildNewsView(controller);
      case SearchType.video:
        return _buildVideoView(controller);
      case SearchType.book:
        return _buildBookView(controller);
      case SearchType.course:
        return _buildCourseView(controller);
      case SearchType.tag:
        return _buildTagView(controller);
      case SearchType.user:
        return _buildUserView(controller);

      // case SearchType.competition:
      //   return _buildCompetitionView(controller);
    }
  }

  Widget _buildTagView(SearchChildController controller) {
    return controller.tagItems.isNotEmpty
        ? ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemBuilder: (_, int index) => GestureDetector(
              onTap: TrackUtils.trackedTap(
                onTap: () {
                  Get.toNamed(Routes.searchTag, arguments: {
                    'tag': controller.tagItems[index],
                  });
                },
                userLogType: '111004',
                params: controller.tagItems[index].id,
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 12.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index < controller.tagItems.length - 1
                          ? '#333333'.hexColor.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.tagItems[index].name ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    SimpleCountTextReverse(
                      count: controller.tagItems[index].viewCount?.abbreviateNumber ?? '0',
                      desc: '阅读',
                      usePlaceHolder: true,
                    ),
                    SimpleCountTextReverse(
                      count: controller.tagItems[index].commentCount?.abbreviateNumber ?? '0',
                      desc: '讨论',
                      usePlaceHolder: true,
                    ),
                  ],
                ),
              ),
            ),
            separatorBuilder: (_, int index) => SizedBox(height: 18.w),
            itemCount: controller.tagItems.length,
          )
        : const Center(child: NoDataView());
  }

  Widget _buildUserView(SearchChildController controller) {
    return controller.userItems.isNotEmpty
        ? ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemBuilder: (context, index) {
              final item = controller.userItems[index];
              String title = '关注';
              if ((item.isfans ?? false) && (item.followed ?? false)) {
                title = '互相关注';
              } else if (!(item.isfans ?? false) && (item.followed ?? false)) {
                title = '已关注';
              } else if ((item.isfans ?? false) && !(item.followed ?? false)) {
                title = '回关';
              }
              return Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      width: 36.w,
                      height: 36.w,
                      fit: BoxFit.cover,
                      imageUrl: item.avatar ?? '',
                      errorWidget: (context, url, error) => Image.asset('assets/images/default_avatar.png'),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        item.nickname ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.onFollowUser(index),
                    child: Container(
                      width: 70.w,
                      height: 28.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.followed == true ? '#EBEBEB'.hexColor : '#557BF6'.hexColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: item.followed == true ? '#333333'.hexColor : Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            itemCount: controller.userItems.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.w),
          )
        : const Center(child: NoDataView());
  }

  Widget _buildCourseView(SearchChildController controller) {
    return controller.courses.isNotEmpty
        ? ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemBuilder: (_, int index) => GestureDetector(
              onTap: TrackUtils.trackedTap(
                onTap: () {
                  Get.toNamed(Routes.articleDetail, arguments: controller.courses[index].targetId ?? 0);
                },
                userLogType: '111003',
                params: controller.courses[index].targetId,
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 16.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index < controller.courses.length - 1
                          ? '#333333'.hexColor.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Text(
                  controller.courses[index].title ?? '',
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            separatorBuilder: (_, int index) => SizedBox(height: 12.w),
            itemCount: controller.courses.length,
          )
        : const Center(child: NoDataView());
  }

  Widget _buildBookView(SearchChildController controller) {
    if (controller.articles.isEmpty) {
      return const Center(
        child: NoDataView(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
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
                        userLogType: '111002',
                        params: controller.articles[firstIndex].id,
                      ),
                      item: controller.articles[firstIndex],
                      itemWidth: itemWidth,
                    ),
                  ),
                  if (hasSecond) ...[
                    SizedBox(width: 11.w),
                    Expanded(
                      child: ThreeDBookItem(
                        onTap: () => TrackUtils.trackEvent(
                          userLogType: '111002',
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

  Widget _buildVideoView(SearchChildController controller) {
    if (controller.articles.isEmpty) {
      return const Center(
        child: NoDataView(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
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
                    userLogType: '111001',
                    params: controller.articles[firstIndex].id,
                  ),
                  item: controller.articles[firstIndex],
                ),
              ),
              if (hasSecond) ...[
                SizedBox(width: 11.w),
                Expanded(
                  child: VideoItem(
                    onTap: () => TrackUtils.trackEvent(
                      userLogType: '111001',
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

  Widget _buildNewsView(SearchChildController controller) {
    return controller.articles.isNotEmpty
        ? ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
            itemBuilder: (_, int index) => NewsItem(item: controller.articles[index]),
            separatorBuilder: (_, int index) => SizedBox(height: 16.w),
            itemCount: controller.articles.length,
          )
        : const Center(child: NoDataView());
  }
}
