import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/mixins/refresh_controller_mixin.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/common_refresher.dart';

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
        decoration: BoxDecoration(
          color: '#F2F9FF'.hexColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: CommonRefresher(
          controller: controller.refreshController,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoading,
          isLoading: controller.isLoading,
          enablePullUp: true,
          // enablePullUp: !controller.noMore,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = controller.items[index];
                    return Container();
                  },
                  childCount: controller.items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
