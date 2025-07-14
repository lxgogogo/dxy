import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/mixins/refresh_controller_mixin.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/utils/debounce_throttle_util.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/common_refresher.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../utils/toast_utils.dart';
import '../feed_post/feed_post_screen.dart';

part 'tag_list_controller.dart';

class TagListScreen extends StatelessWidget {
  const TagListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TagListController>(
      init: TagListController(),
      builder: (controller) => Container(
        margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.w, bottom: 20.w),
              child: Row(
                children: [
                  Text(
                    '添加话题',
                    style: TextStyle(color: '#333333'.hexColor, fontSize: 20.sp, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.find<FeedPostController>().addSelectTags(controller.selectedItems);
                      Get.back();
                    },
                    child: Text(
                      '完成',
                      style: TextStyle(
                        color: '#557BF6'.hexColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
            buildSearchInput(controller),
            SizedBox(height: 8.w),
            buildTagList(controller),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: IndexedStack(
                    index: controller.showSearchResult ? 0 : 1,
                    children: [
                      CommonRefresher(
                        scrollController: controller.searchScrollController,
                        controller: controller.searchRefreshController,
                        onLoading: controller.onSearchLoading,
                        enablePullDown: false,
                        enablePullUp: true,
                        child: controller.items.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 7.w),
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: controller.items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildItem(controller.items[index], controller);
                                },
                              )
                            : const Center(child: NoDataView()),
                      ).scrollToTopWrapper(
                        controller.searchScrollController,
                      ),
                      CommonRefresher(
                        scrollController: controller.hotScrollController,
                        controller: controller.refreshController,
                        onLoading: controller.onLoading,
                        enablePullDown: false,
                        enablePullUp: true,
                        child: controller.hotItems.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 7.w),
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: controller.hotItems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildItem(controller.hotItems[index], controller);
                                },
                              )
                            : const SizedBox(),
                      ).scrollToTopWrapper(
                        controller.hotScrollController,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    TagModel item,
    TagListController controller,
  ) {
    return GestureDetector(
      onTap: () {
        controller.addSelectTag(item);
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '#${item.name ?? ''}',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${_formatViewCount(item.viewCount ?? 0)} 讨论',
              style: TextStyle(
                color: '#999999'.hexColor,
                fontSize: 12.sp,
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatViewCount(int count) {
    if (count >= 10000) {
      final wan = count / 10000;
      // 检查是否为整数万（如 10000、20000）
      final isInteger = wan % 1 == 0;
      return isInteger ? '${wan.toInt()}万' : '${wan.toStringAsFixed(1)}万';
    }
    return '$count';
  }

  Widget buildTagList(TagListController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '还可以添加${Get.find<FeedPostController>().tagMaxLength - controller.selectedItems.length}个标签',
            style: TextStyle(
              fontSize: 10.sp,
              color: '#999999'.hexColor,
            ),
          ),
          SizedBox(height: 12.w),
          Container(
            padding: EdgeInsets.only(bottom: 12.w),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(color: '#000000'.hexColor.withOpacity(0.05), width: 0.5.w),
            )),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 8.w,
              children: [
                ...List.generate(
                  controller.selectedItems.length,
                  (index) {
                    final tag = controller.selectedItems[index];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 28.w,
                          padding: EdgeInsets.only(left: 12.w, right: 8.w),
                          decoration: ShapeDecoration(
                            color: '#557BF6'.hexColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag.name ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: '#557BF6'.hexColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.removeTag(index),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: SvgPicture.asset(
                                    Assets.svg.iconClose,
                                    width: 10.w,
                                    height: 10.w,
                                    color: '#557BF6'.hexColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchInput(TagListController controller) {
    return Container(
      height: 32.w,
      padding: EdgeInsets.only(left: 12.w, right: 6.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
              controller: controller.searchController,
              keyboardType: TextInputType.text,
              autocorrect: false,
              focusNode: controller.searchFocusNode,
              onChanged: controller.onChanged,
              style: TextStyle(
                fontSize: 12.sp,
                color: '#333333'.hexColor,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: '搜索话题',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
                isDense: true,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: '#333333'.hexColor.withOpacity(0.7),
                ),
              ),
            ),
          ),
          if (controller.searchController.text.isNotEmpty)
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
}
