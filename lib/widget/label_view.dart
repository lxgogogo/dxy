import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:holdem/page/comment/page_comment.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../page/forum/page_comment_input.dart';
import '../utils/app_theme.dart';
import '../view/forum/ToastUtils.dart';

class LabelView extends StatefulWidget {
  bool isEditLabel = false;
  List<String> labelData = [];

  LabelView({Key? key, required this.isEditLabel, required this.labelData})
      : super(key: key);

  @override
  _LabelViewState createState() => _LabelViewState();
}

class _LabelViewState extends State<LabelView> {
  late bool isEditLabel = false;
  late List<String> labelData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isEditLabel = widget.isEditLabel;
    labelData = widget.labelData;
    return ReorderableGridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: isEditLabel ? 3 : 4,
      childAspectRatio: isEditLabel ? 3 : 2.5,
      // 设置宽高比为
      dragEnabled: false,
      dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
            return child;
          }),
      children: this.labelData.map((e) => buildItem("$e")).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final element = labelData.removeAt(oldIndex);
          labelData.insert(newIndex, element);
        });
      },
    );
  }

  Widget buildItem(String text) {
    return Container(
        key: ValueKey(text),
        decoration: BoxDecoration(
          color: AppTheme.color_1A008EFF,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
        child: Row(
          children: [
            Expanded(
                child: Center(
                    child: Text(
              maxLines: 1,
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.color_008EFF,
              ),
            ))),
            Visibility(
              child: Row(
                children: [
                  Text(
                    '丨',
                    style: TextStyle(
                        color: AppTheme.color_999999,
                        fontWeight: FontWeight.w200),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.close,
                      size: 15,
                    ),
                  )
                ],
              ),
              visible: isEditLabel ? true : false,
            )
          ],
        ));
  }
}
