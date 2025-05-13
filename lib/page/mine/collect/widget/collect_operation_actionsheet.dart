
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';

import 'collect_operation_alert.dart';

class CollectOperationSheet {

  static actionSheet(Function selectOnTap, {bool showMoveBtn = true}) {
    Get.bottomSheet(
        CollectOperationWidget(
            selectOnTap: selectOnTap, showMoveBtn: showMoveBtn),
        barrierColor: Colors.transparent);
  }
}

class CollectOperationWidget extends StatefulWidget {

  final bool showMoveBtn;
  final Function selectOnTap;

  const CollectOperationWidget({super.key, required this.selectOnTap, this.showMoveBtn = true});

  @override
  State<StatefulWidget> createState() {
    return _CollectOperationWidgetState();
  }
}

class _CollectOperationWidgetState extends State<CollectOperationWidget> {

  final List<CollectOperationModel> _dataList = [
    CollectOperationModel(title: '新增内容', select: false, index: 0),
    CollectOperationModel(title: '修改名称', select: false, index: 2),
    CollectOperationModel(title: '删除分类', select: true, index: 3),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showMoveBtn) {
      _dataList.insert(1,CollectOperationModel(title: '移出分类', select: false, index: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 50.w*_dataList.length+20.w,
      padding: EdgeInsets.symmetric(vertical: 20.w).copyWith(top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
      ),
      child: Wrap(
        children: [
          ..._dataList.map((e) {
            return _buildItemWidget(e);
          })
        ],
      )
    );
  }

  Widget _buildItemWidget(e) {
    return GestureDetector(
        onTap: () {
          Get.close(1);
          widget.selectOnTap(e.index ?? 0);
        },
        child: Container(
          height: 50.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.w,
                color: ColorStyle.c333333.withOpacity(0.05)
              )
            )
          ),
          child: Text(
            e.title ?? '',
            style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.color_333333),
          ),
        ));
  }
}