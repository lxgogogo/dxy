import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      body: Obx(() => SmartRefresher(
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
              itemCount: controller.collectList.length)))
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
}