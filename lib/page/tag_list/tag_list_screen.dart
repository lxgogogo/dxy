import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/utils/debounce_throttle_util.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/common_refresher.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
        decoration: BoxDecoration(
          color: '#F2F9FF'.hexColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: Column(
          children: [
            CommonAppBar.arrowBack(
              context,
              title: '详情',
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: '#E6E6E6'.hexColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      focusNode: controller.searchFocusNode,
                      onChanged: controller.onChanged,
                      style: TextStyle(
                        color: '#2a2a2a'.hexColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '# 请输入话题',
                        hintStyle: TextStyle(
                          color: '#95A3C4'.hexColor,
                          fontSize: 14.sp,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        disabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                  if (controller.searchController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: GestureDetector(
                        onTap: controller.onClear,
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: controller.showSearchResult
                    ? CommonRefresher(
                        controller: controller.searchRefreshController,
                        onLoading: controller.onSearchLoading,
                        enablePullDown: false,
                        enablePullUp: true,
                        child: controller.items.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8.w),
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: controller.items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.back(result: controller.items[index]);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.w),
                                      child: Text(
                                        controller.items[index].name ?? '',
                                        style: TextStyle(
                                          color: '#3B5078'.hexColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(child: NoDataView()),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.w),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: controller.hotItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Get.back(result: controller.hotItems[index]);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.w),
                              child: Text(
                                controller.hotItems[index].name ?? '',
                                style: TextStyle(
                                  color: '#3B5078'.hexColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
