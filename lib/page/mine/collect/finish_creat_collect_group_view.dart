import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/common_app_bar.dart';
import '../../../widget/common_done_button.dart';
import '../widgets/mine_collect_item.dart';
import 'finish_creat_collect_group_controller.dart';

class FinishCreatCollectGroupPage extends StatefulWidget {
  const FinishCreatCollectGroupPage({Key? key}) : super(key: key);

  @override
  State<FinishCreatCollectGroupPage> createState() =>
      _FinishCreatCollectGroupPageState();
}

class _FinishCreatCollectGroupPageState
    extends State<FinishCreatCollectGroupPage> {
  final FinishCreatCollectGroupController controller =
      Get.put(FinishCreatCollectGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '从全部收藏中选择', actions: [
          GestureDetector(
            onTap: controller.finishOnTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '完成',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.color_557BF6
                ),
              ),
            ),
          )
        ]),
        body: Obx(() => SmartRefresher(
            scrollController: controller.scrollController,
            enablePullDown: true,
            enablePullUp: true,
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoading,
            child: controller.loaded.value && controller.collectList.isEmpty
                ? const Center(child: NoDataView())
                : ListView.builder(
                    itemBuilder: (c, i) {
                      return _buildItemWidget(i);
                    },
                    itemCount: controller.collectList.length)).scrollToTopWrapper(
          controller.scrollController,
        )));
  }

  @override
  void dispose() {
    Get.delete<FinishCreatCollectGroupController>();
    super.dispose();
  }

  // TODO: Build Widget

  Widget _buildItemWidget(int index) {
    final model = controller.collectList[index];
    return Row(
      children: [
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () {
            controller.selectOnTap(index);
          },
          child: Container(
            padding: EdgeInsets.all(5.w),
            color: Colors.transparent,
            child: Image.asset(
              (model.select ?? false)
                  ? Assets.images.iconCollectSelect.path
                  : Assets.images.iconCollectNormal.path,
              width: 16.w,
              height: 16.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(child: MyCollectItem(item: model))
      ],
    );
  }
}
