import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/search_top.dart';
import 'package:holdem/page/search/widgets/search_child_view.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import '../../utils/track_utils.dart';
import '../../widget/custom_underline_tab_indicator.dart';
import '../../widget/dialog_common.dart';

part 'search_controller.dart';

enum SearchType {
  // news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course'),
  tag('话题', categoryAlias: ''),
  user('用户', categoryAlias: '');

  // competition('赛事', categoryAlias: 'competition');

  final String title;

  final String categoryAlias;

  const SearchType(this.title, {required this.categoryAlias});
}

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: GetBuilder<SearchController>(
          init: SearchController(),
          builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 0.0,
                leading: UnconstrainedBox(
                  child: GestureDetector(
                    onTap: () {
                      if (controller.showResult) {
                        controller.onClear();
                        return;
                      }
                      Get.back();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 4.w),
                      child: Image.asset(
                        'assets/images/navi_back.png',
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                title: buildSearchInput(),
                actions: [
                  GestureDetector(
                    onTap: TrackUtils.trackedTap(
                      onTap: () => controller.onSearch(context),
                      userLogType: '110001',
                      params: controller.controller.text,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 16.w),
                      child: Text(
                        '搜索',
                        style: TextStyle(
                          color: '#557BF6'.hexColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              backgroundColor: Colors.white,
              body: controller.showResult
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: TabBar(
                            controller: controller.tabController,
                            tabs: SearchType.values
                                .map((e) => Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                                      child: Tab(text: e.title),
                                    ))
                                .toList(),
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            indicator: RoundUnderlineTabIndicator(
                              borderSide: BorderSide(width: 2.w, color: const Color(0xff4260FF)),
                              wantToWith: 12.w,
                            ),
                            enableFeedback: false,
                            overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                              return Colors.transparent;
                            }),
                            dividerHeight: 0,
                            labelStyle: TextStyle(
                              color: const Color(0xff2c2c2c),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: TextStyle(
                              color: const Color(0xff666666),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: controller.tabController,
                            children: SearchType.values.map((e) => SearchChildView(type: e).keepAlive).toList(),
                          ),
                        )
                      ],
                    )
                  : buildSearchHistory(context),
            );
          }),
    );
  }

  Widget buildSearchInput() {
    return Container(
      height: 32.w,
      padding: EdgeInsets.only(left: 12.w, right: 6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        color: '#333333'.hexColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.svg.iconSearchHistory,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller.controller,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autofocus: true,
              onChanged: controller.onChanged,
              style: TextStyle(
                fontSize: 12.sp,
                color: '#333333'.hexColor,
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: InputDecoration(
                counterText: "",
                hintText: '请输入你想搜索的内容',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
                isDense: true,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: '#333333'.hexColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
          if (controller.controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.onClear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Assets.images.clear.image(
                  width: 16.w,
                  height: 16.w,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSearchHistory(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.historyItems.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svg.clubs,
                      width: 12.w,
                      height: 12.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '历史记录',
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => CommonDialog(
                        title: '删除历史',
                        content: '确定要删除全部历史吗？',
                        confirmText: '确认删除',
                        onConfirm: () {
                          Navigator.of(context).pop();
                          controller.deleteAllHistory();
                        },
                        cancelText: '取消',
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    Assets.svg.iconHistoryDelete,
                    width: 14.w,
                    height: 14.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final itemWidth = (constraints.maxWidth - 24.w) / 2;
                return Wrap(
                  spacing: 24.w,
                  runSpacing: 12.w,
                  alignment: WrapAlignment.start,
                  children: [
                    ...List.generate(
                      controller.historyItems.length,
                      (index) {
                        return GestureDetector(
                          onTap: TrackUtils.trackedTap(
                            onTap: () {
                              controller.controller.text = controller.historyItems[index];
                              controller.onSearch(context);
                            },
                            userLogType: '110003',
                            params: controller.historyItems[index],
                          ),
                          onLongPress: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => CommonDialog(
                                title: '删除历史',
                                content: '确认删除当前搜索记录吗？',
                                confirmText: '确认',
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  controller.deleteItemHistory(index);
                                },
                                cancelText: '取消',
                              ),
                            );
                          },
                          child: Container(
                            width: itemWidth,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.historyItems[index],
                              style: TextStyle(
                                color: '#333333'.hexColor,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              },
            ),
            SizedBox(height: 16.w),
          ],
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.spades,
                width: 12.w,
                height: 12.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '热搜推荐',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.w,
            alignment: WrapAlignment.start,
            children: [
              ...List.generate(
                controller.hotTagItems.length,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      // Get.toNamed(Routes.searchTag, arguments: {
                      //   'tag': controller.hotTagItems[index],
                      // });
                      final item = controller.hotTagItems[index];
                      final id = item.id;
                      String eventName = '';
                      if (item.type == 'book') {
                        eventName = '书籍';
                        Get.toNamed(Routes.bookDetail, arguments: id);
                      } else if (item.type == 'article') {
                        eventName = '教程';
                        Get.toNamed(Routes.articleDetail, arguments: id);
                      } else if (item.type == 'tool') {
                        eventName = '工具';
                        Get.toNamed(Routes.toolDetail, arguments: id);
                      } else if (item.type == 'video' || item.type == 'videoList') {
                        eventName = '视频';
                        Get.toNamed(Routes.videoDetail, arguments: {'id': id});
                      } else if (item.type == 'thread') {
                        eventName = '帖子';
                        Get.toNamed(Routes.feedDetail, arguments: id);
                      }
                      TrackUtils.trackEvent(userLogType: '110002', params: [id.toString(), eventName].join(','));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.w),
                      decoration: BoxDecoration(
                        color: '#557BF6'.hexColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Text(
                        controller.hotTagItems[index].title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: '#557BF6'.hexColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
