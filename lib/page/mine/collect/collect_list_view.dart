import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/color_style_util.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/no_data.dart';
import '../widgets/mine_collect_item.dart';
import 'collect_list_controller.dart';
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
    return Scaffold(
      appBar: CommonAppBar.arrowBack(context, title: '德州课程', actions: [
        GestureDetector(
          onTap: () {
            CollectOperationAlert.show((index) {
              controller.selectAlertOnTap(index);
            });
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
      body: Obx(() => Column(
        children: [
          Expanded(child: SmartRefresher(
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
                  itemCount: controller.collectList.length))),
          if (controller.isDeleting.value)
            _buildSelectAllWidget()
          else
            const SizedBox()
        ],
      ))
    );
  }

  @override
  void dispose() {
    Get.delete<CollectListController>();
    super.dispose();
  }

  // TODO: Build Widget

  Widget _buildItemWidget(int index) {
    final model = controller.collectList[index];
    return Row(
      children: [
        if (controller.isDeleting.value)...[
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
                  '移出',
                  style: TextStyle(
                      fontSize: 12.w,
                      color: ColorStyle.c333333.withOpacity(0.1),
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 60.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorStyle.cFF3333.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(4.w))
              ),
              child: Text(
                '移出',
                style: TextStyle(
                  fontSize: 12.w,
                  color: ColorStyle.cFF3333,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}