import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../utils/app_theme.dart';

typedef void OnTapCallback(String value);

class LabelView extends StatefulWidget {
  bool isEditLabel = false;
  List<String> labelData = [];
  OnTapCallback onTap;

  LabelView({Key? key, required this.isEditLabel, required this.labelData, required this.onTap})
      : super(key: key);

  @override
  _LabelViewState createState() => _LabelViewState();
}

class _LabelViewState extends State<LabelView> {
  late bool isEditLabel = false;
  late List<String> labelData = [];
  late OnTapCallback onTap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isEditLabel = widget.isEditLabel;
    labelData = widget.labelData;
    onTap = widget.onTap;
    return ReorderableGridView.count(
      key: ValueKey('label'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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

  Widget buildItem(String labelValue) {
    return GestureDetector(
        key: ValueKey('label'),
        onTap: () {
          //item点击
          if (onTap != null) {
            onTap(labelValue);
          }
        },
        child: Container(
            key: ValueKey('label'),
            // width: isEditLabel ? 109.px : 68.px,
            height: isEditLabel ? 30.px : 25.px,
            decoration: BoxDecoration(
              color: AppTheme.color_1A008EFF,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            // 设置内边距
            child: Row(
              children: [
                Expanded(
                    child: Center(
                        child: Text(
                  maxLines: 1,
                          labelValue,
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
            )));
  }
}
