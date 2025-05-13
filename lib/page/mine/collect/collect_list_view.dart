import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/color_style_util.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/dialog_common.dart';
import '../../../widget/no_data.dart';
import '../widgets/mine_collect_item.dart';
import 'collect_list_controller.dart';
import 'widget/collect_operation_actionsheet.dart';
import 'widget/collect_operation_alert.dart';

class CollectListPage extends StatefulWidget {
  const CollectListPage({Key? key}) : super(key: key);

  @override
  State<CollectListPage> createState() => _CollectListPageState();
}

class _CollectListPageState extends State<CollectListPage> {
  final CollectListController controller = Get.put(CollectListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        appBar: CommonAppBar.arrowBack(context,
            title: controller.selectAllCount.value > 0
                ? '已选${controller.selectAllCount.value}条'
                : controller.name.value,
            actions: [
              if (controller.isDeleting.value)
                GestureDetector(
                    onTap: controller.deleteCollectList,
                    child: Container(
                      padding: EdgeInsets.all(5.w).copyWith(right: 16.w),
                      color: Colors.transparent,
                      child: Text(
                        '移出',
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: ColorStyle.cFF3333,
                            fontWeight: FontWeight.w600),
                      ),
                    ))
              else
                GestureDetector(
                  onTap: () {
                    CollectOperationSheet.actionSheet((index) {
                      controller.selectAlertOnTap(index);
                    },
                        showMoveBtn:
                            controller.collectList.isEmpty ? false : true);
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    margin: EdgeInsets.only(right: 5.w),
                    color: Colors.transparent,
                    child: Image.asset(
                      Assets.images.iconCollectMore.path,
                      width: 24.w,
                      height: 24.w,
                      color: Colors.black,
                    ),
                  ),
                )
            ]),
        body: Column(
          children: [
            Expanded(child: _buildCollectListWidget()),
            if (controller.isDeleting.value)
              _buildSelectAllWidget()
            else
              const SizedBox()
          ],
        )));
  }

  @override
  void dispose() {
    Get.delete<CollectListController>();
    super.dispose();
  }

  // TODO: Build Widget

  Widget _buildCollectListWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return SlidableAutoCloseBehavior(
            child: Obx(() => SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: controller.refreshController,
                onRefresh: controller.onRefresh,
                onLoading: controller.onLoading,
                child: controller.loaded.value && controller.collectList.isEmpty
                    ? const Center(child: NoDataView())
                    : ListView.builder(
                        itemBuilder: (c, i) {
                          return Slidable(
                              groupTag: '1-list',
                              key: ValueKey('${controller.collectList[i].id}'),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 42 / maxWidth,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) => CommonDialog(
                                          title: '删除收藏',
                                          content: '确定要删除这个收藏吗？',
                                          confirmText: '确认删除',
                                          onConfirm: () {
                                            Navigator.of(context).pop();
                                            controller.deleteItem(i);
                                          },
                                        ),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'assets/svg/icon_delete.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ],
                              ),
                              child: _buildItemWidget(i));
                        },
                        itemCount: controller.collectList.length))));
      },
    );
  }

  Widget _buildItemWidget(int index) {
    final model = controller.collectList[index];
    return Row(
      children: [
        if (controller.isDeleting.value) ...[
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
          )
        ],
        Expanded(child: MyCollectItem(item: model))
      ],
    );
  }

  Widget _buildSelectAllWidget() {
    return Container(
      height: 80.w,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.w),
      color: ColorStyle.white.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.selectAllOnTap,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.w),
                  color: Colors.transparent,
                  child: Image.asset(
                    controller.isSelectAll.value
                        ? Assets.images.iconCollectSelect.path
                        : Assets.images.iconCollectNormal.path,
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  '全选',
                  style: TextStyle(
                    fontSize: 14.w,
                    color: AppTheme.color_333333,
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 40.w)
        ],
      ),
    );
  }
}
