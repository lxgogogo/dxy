import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../utils/app_theme.dart';

typedef void OnTapCallback(String value);

class LabelView extends StatefulWidget {
  bool isEditLabel = false;
  List<String> labelData = [];
  OnTapCallback onItemTap;
  OnTapCallback onDelTap;

  LabelView({Key? key, required this.isEditLabel, required this.labelData, required this.onItemTap,required this.onDelTap})
      : super(key: key);

  @override
  _LabelViewState createState() => _LabelViewState();
}

class _LabelViewState extends State<LabelView> {
  late bool isEditLabel = false;
  late List<String> labelData = [];
  late OnTapCallback onTap;
  late OnTapCallback onDelTap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isEditLabel = widget.isEditLabel;
    labelData = widget.labelData;
    onTap = widget.onItemTap;
    onDelTap = widget.onDelTap;
    return ReorderableGridView.builder(
      key: ValueKey('label1'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: isEditLabel ? 3 : 4,
        childAspectRatio: isEditLabel ? 3 : 2.5,
      ),
      // 设置宽高比为
      dragEnabled: false,
      dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
            return child;
          }),
      // children: this.labelData.map((e) => buildItem("$e")).toList(),
      onReorder: (oldIndex, newIndex) {
        // setState(() {
        //   final element = labelData.removeAt(oldIndex);
        //   labelData.insert(newIndex, element);
        // });
      },
      itemCount: labelData.length,
      itemBuilder: (BuildContext context, int index) {
        return buildItem(labelData[index]);
    },
    );
  }

  Widget buildItem(String labelValue) {
    return GestureDetector(
        key: ValueKey('label2'),
        onTap: () {
          //item点击
          if (onTap != null) {
            onTap(labelValue);
          }
        },
        child: Container(
            key: ValueKey('label3'),
            // width: isEditLabel ? 109.px : 68.px,
            height: isEditLabel ? 30.px : 25.px,
            decoration: BoxDecoration(
              color: AppTheme.color_1A008EFF,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            // 设置内边距
            child: Row(
              children: [
                Expanded(
                    child: Center(
                        child: Text(
                  maxLines: 1,
                          labelValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.color_008EFF,
                  ),
                ))),
                Visibility(
                  child: Row(
                    children: [
                      Text(
                        '|',
                        style: TextStyle(
                            color: AppTheme.color_999999,
                            fontWeight: FontWeight.w200),
                      ),
                    // IconButton(
                    //   icon: Image.asset(
                    //     'assets/images/label_close.png',
                    //     width: 15.px,
                    //     height: 15.px,
                    //   ),
                    //   onPressed: () {
                    //       setState(() {
                    //         labelData.remove(labelValue);
                    //       });
                    //   },
                    // )
                      SizedBox(width: 3.px,),
                      GestureDetector(
                        onTap: () { //删除当前标签
                          onDelTap(labelValue);

                        },
                        child: Icon(
                          Icons.close,
                          size: 15.px,
                        ),
                      ),
                      SizedBox(width: 3.px,)
                    ],
                  ),
                  visible: isEditLabel ? true : false,
                )
              ],
            )));
  }
}
