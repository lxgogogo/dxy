import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
import 'package:holdem/widget/item_article.dart';
import 'package:holdem/widget/item_book.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/item_competition.dart';
import 'package:holdem/widget/item_tag.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
          enablePullUp: true,
          controller: controller.refreshController,
          onLoading: controller.onLoading,
          child: controller.isLoaded ? _buildView(controller) : const SizedBox(),
        );
      },
    );
  }

  Widget _buildView(SearchChildController controller) {
    switch (type) {
      case SearchType.news:
        return _buildNewsView(controller);
      case SearchType.video:
        return _buildVideoView(controller);
      case SearchType.book:
        return _buildBookView(controller);
      case SearchType.course:
        return _buildCourseView(controller);
      case SearchType.user:
        return _buildUserView(controller);
      case SearchType.tag:
        return _buildTagView(controller);
      case SearchType.competition:
        return _buildCompetitionView(controller);
    }
  }

  Widget _buildCompetitionView(SearchChildController controller) {
    return controller.competitionItems.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
            itemBuilder: (context, index) => CompetitionItem(item: controller.competitionItems[index]),
            itemCount: controller.competitionItems.length,
          )
        : const NoDataView();
  }

  Widget _buildTagView(SearchChildController controller) {
    return controller.tagItems.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
            itemBuilder: (c, i) => TagItem(tag: controller.tagItems[i]),
            itemCount: controller.tagItems.length,
          )
        : const NoDataView();
  }

  Widget _buildUserView(SearchChildController controller) {
    return controller.userItems.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) => Container(
              height: 58.w,
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xffE6E6E6), width: 1.w))),
              child: Row(children: [
                BorderAvatar(avatar: controller.userItems[index].avatar ?? ''),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  controller.userItems[index].nickname!.isNotEmpty ? controller.userItems[index].nickname! : '',
                  style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 12.w),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.onFollowUser(index),
                  child: controller.userItems[index].followed == true
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
            itemCount: controller.userItems.length,
          )
        : const NoDataView();
  }

  Widget _buildCourseView(SearchChildController controller) {
    return controller.courses.isNotEmpty
        ? CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: 'b9d0e5'.hexColor.withOpacity(0.64),
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
                        color: 'bfd2e2'.hexColor.withOpacity(0.81),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.w),
                      ),
                      BoxShadow(
                        color: 'f8fbff'.hexColor,
                      ),
                    ],
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

  Widget _buildBookView(SearchChildController controller) {
    return controller.articles.isNotEmpty
        ? ListView.builder(
            itemBuilder: (c, i) => BookItem(article: controller.articles[i]),
            itemCount: controller.articles.length,
          )
        : const NoDataView();
  }

  Widget _buildVideoView(SearchChildController controller) {
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

  Widget _buildNewsView(SearchChildController controller) {
    return controller.articles.isNotEmpty
        ? ListView.builder(
            itemBuilder: (c, i) => ArticleItem(article: controller.articles[i]),
            itemCount: controller.articles.length,
          )
        : const NoDataView();
  }
}
