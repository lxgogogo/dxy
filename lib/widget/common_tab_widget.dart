
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonTabWidget extends StatefulWidget {

  final Function selectOnTap;

  const CommonTabWidget({super.key, required this.selectOnTap});

  @override
  State<StatefulWidget> createState() {
    return _CommonTabWidgetState();
  }
}

class _CommonTabWidgetState extends State<CommonTabWidget> {

  final List<CommonTabWidgetModel> _dataList = [
    CommonTabWidgetModel(
      index: 0,
      title: '全部收藏',
      select: true
    ),
    CommonTabWidgetModel(
        index: 1,
        title: '收藏分类',
        select: false
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      children: [
        ..._dataList.map((e) {
          return _buildSelectItemWidget(e);
        })
      ],
    );
  }

  Widget _buildSelectItemWidget(item) {
    return GestureDetector(
      onTap: () {
        for (final model in _dataList) {
          model.select = false;
        }
        item.select = true;
        if (mounted) {
          setState(() {});
        }
        widget.selectOnTap(item.index ?? 0);
      },
      child: Container(
        padding: EdgeInsets.all(5.w),
        color: Colors.transparent,
        child: Text(
          item.title ?? '',
          style: TextStyle(
              fontSize: 14.w,
              color: (item.select ?? false) ? Colors.black : Colors.black.withOpacity(0.8),
              fontWeight: (item.select ?? false) ? FontWeight.bold : FontWeight.normal
          ),
        )
      ),
    );
  }
}

class CommonTabWidgetModel {

  String? title;
  bool? select;
  int? index;

  CommonTabWidgetModel({this.title, this.select, this.index});
}