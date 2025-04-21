
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/stores/user_store.dart';

class CollectOperationAlert {
  static show(Function selectOnTap) {
    Get.dialog(CollectOperationWidget(selectOnTap: selectOnTap), barrierColor: Colors.transparent);
  }
}

class CollectOperationWidget extends StatefulWidget {

  final Function selectOnTap;
  const CollectOperationWidget({super.key, required this.selectOnTap});

  @override
  State<StatefulWidget> createState() {
    return _CollectOperationWidgetState();
  }
}

class _CollectOperationWidgetState extends State<CollectOperationWidget>{
  final List<CollectOperationModel> _dataList = [
    CollectOperationModel(title: '新增内容', select: false, index: 0),
    CollectOperationModel(title: '移出分类', select: false, index: 1),
    CollectOperationModel(title: '修改名称', select: false, index: 2),
    CollectOperationModel(title: '删除分类', select: true, index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(
            right: 20.w,
            top: kToolbarHeight,
            child: Container(
              width: 72.w,
              height: 30.w*_dataList.length+8.w,
              padding: EdgeInsets.only(top: 4.w, bottom: 4.w),
              decoration: BoxDecoration(
                color: '#FCFCFC'.hexColor,
                borderRadius: BorderRadius.all(Radius.circular(6.w)),
                boxShadow: [
                  BoxShadow(
                      color: "#000000".hexColor.withOpacity(0.1),
                      offset: const Offset(0, 3),
                      blurRadius: 8, spreadRadius: 0)
                ]
              ),
              child: Wrap(
                children: [
                  ..._dataList.map((e) {
                    return _buildItemWidget(e);
                  })
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemWidget(e) {
    return GestureDetector(
      onTap: () {
        Get.close(1);
        widget.selectOnTap(e.index ?? 0);
      },
      child: Container(
        height: 30.w,
        alignment: Alignment.center,
        child: Text(
          e.title ?? '',
          style: TextStyle(
            fontSize: 12.w,
            color: (e.select ?? false) ? Colors.red : '#333333'.hexColor
          ),
        ),
      )
    );
  }
}

class CollectOperationModel {

  String? title;
  bool? select;
  int? index;

  CollectOperationModel({this.title, this.select, this.index});
}