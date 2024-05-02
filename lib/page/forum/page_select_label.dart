import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:holdem/widget/label_view.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';

class SelectLabelPage extends StatefulWidget {
  SelectLabelPage({Key? key}) : super(key: key);

  @override
  _SelectLabelPageState createState() => _SelectLabelPageState();
}

class _SelectLabelPageState extends State<SelectLabelPage> {
  late bool isEditLabel = false;
  late bool isShowCreateInputView = false;
  List<String> labelData = [
    '标签1',
    '标签2',
    '标签13',
    '标签14',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '选择标签',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.color_F3F3F3,
            thickness: 1,
          ),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                setState(() {
                  isShowCreateInputView = true;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Text(
                  '创建标签',
                  style: AppTheme.text3B5078Size15,
                ),
              ))
        ],
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: Colors.white,
      bottomSheet: bottomView(),
    );
  }

  Widget contentView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                margin: EdgeInsets.only(left: 16),
                child: Text(
                  '我的标签',
                  style: AppTheme.text333333Size15,
                )),
            IconButton(
              icon: Image.asset(
                'assets/images/label_del.png',
                width: 16.px,
                height: 16.px,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: LabelView(isEditLabel: true, labelData: labelData))
            )
      ],
    );
  }

  Widget buildItem(String text) {
    return Container(
      height: 30,
      key: ValueKey(text),
      decoration: BoxDecoration(
        color: AppTheme.color_1A008EFF,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // 设置内边距
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.color_008EFF,
        ),
      ),
    );
  }

  Widget bottomView() {
    return Visibility(
        child: Container(
            height: 70,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  height: 0.5,
                  color: AppTheme.color_F3F3F3,
                ),
                Container(
                  height: 69,
                  padding: EdgeInsets.fromLTRB(16, 15, 16, 15),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '标签内容',
                            filled: true,
                            fillColor: AppTheme.color_EFEFEF,
                            hintStyle: AppTheme.text999999Size14,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.color_008EFF,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.fromLTRB(16, 9, 16, 9),
                            child: Text('创建', style: AppTheme.textFFFFFFSize16),
                          ))
                    ],
                  ),
                )
              ],
            )),
        visible: isShowCreateInputView ? true : false);
  }
}
