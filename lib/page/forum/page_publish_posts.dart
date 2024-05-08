import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_ait_user.dart';
import 'package:holdem/page/forum/page_select_label.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../utils/app_theme.dart';
import '../../widget/label_view.dart';

class PublishPostsPage extends StatefulWidget {
  const PublishPostsPage({super.key});

  @override
  State<PublishPostsPage> createState() => _PublishPostsPageState();
}

class _PublishPostsPageState extends State<PublishPostsPage>
    with SingleTickerProviderStateMixin {
  late int currentPostId;
  final TextEditingController controllerTitle = TextEditingController();
  final controller = DetectableTextEditingController(
    regExp: detectionRegExp(),
  );

  final imageData = [];

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  final customLabel = <String>[];

  String aitUserContent = ''; //@用户的内容

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
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
          '发帖',
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
          IconButton(
              onPressed: () {
                //提交评论
                String title = controllerTitle.text;
                String content = controller.text;
              },
              icon: Image.asset(
                'assets/images/release.png',
                width: 50.px,
                height: 29.px,
              ))
        ],
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: Colors.white,
      bottomSheet: bottomView(),
    );
  }

  Widget contentView() {
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          height: 45.px,
          child: TextFormField(
              maxLines: 1,
              style: AppTheme.text000000Size16W500,
              controller: controllerTitle,
              decoration: const InputDecoration(
                hintText: '起个标题吧',
                hintStyle: AppTheme.text999999Size16W500,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.color_F3F3F3),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.color_F3F3F3),
                ),
                filled: true,
                fillColor: Colors.white,
              )),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16, 5, 16, 0),
          height: 150.px,
          child: DetectableTextField(
              maxLines: 5,
              style: AppTheme.text000000Size16,
              controller: controller,
              onChanged: (text) {
                // _updateText();
              },
              decoration: const InputDecoration(
                hintText: '请输入正文',
                hintStyle: AppTheme.text999999Size16,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              )),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
            child: imageGridView(),
          ),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.fromLTRB(14.px, 6.px, 14.px, 0),
                child: LabelView(
                  isEditLabel: false,
                  labelData: customLabel,
                  onTap: (labelValue){

                  },
                )))
      ],
    );
  }

  Widget imageGridView() {
    return ReorderableGridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      dragEnabled: false,
      dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
            return child;
          }),
      children: this.imageData.map((e) => buildItem("$e")).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final element = imageData.removeAt(oldIndex);
          imageData.insert(newIndex, element);
        });
      },
      footer: [
        IconButton(
            onPressed: () {
              openFilePicker();
            },
            icon: Image.asset(
              'assets/images/image_add.png',
              width: 111,
              height: 111,
              fit: BoxFit.cover,
            )),
      ],
    );
  }

  Widget buildItem(String text) {
    if (text.isNotEmpty && text.contains('http')) {
      return Center(
          key: ValueKey(text),
          child: Image.network(
            text,
            width: 101,
            height: 101,
            fit: BoxFit.cover,
          ));
    } else {
      return Center(
          key: ValueKey(text),
          child: Stack(
            children: [
              Image.file(
                File(text),
                width: 98,
                height: 98,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: -10,
                top: -10,
                child: IconButton(
                    onPressed: () {
                      //跳转评论列表页面
                      setState(() {
                        imageData.remove(text);
                      });
                    },
                    icon: Image.asset(
                      'assets/images/close_black.png',
                      width: 25.px,
                      height: 25.px,
                    )),
              )
            ],
          ));
    }
  }

  Widget bottomView() {
    return Container(
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
              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AitUserPage()),
                            );
                            // 在这里处理从ResultPage返回的结果
                            if (result != null) {
                              UserBean user =
                                  UserBean(result.name, result.isFollowed);
                              setState(() {
                                String originalContent = controller.text;
                                controller.text =
                                    '@${user.name} $originalContent';
                                print('forumLog=====' + aitUserContent);
                              });
                            }
                          },
                          icon: Image.asset(
                            'assets/images/ait.png',
                            width: 25.px,
                            height: 25.px,
                          )),
                      IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectLabelPage()),
                            );
                            // 在这里处理从ResultPage返回的标签主体
                            if (result != null) {
                              setState(() {
                                customLabel.add(result);
                              });
                            }
                          },
                          icon: Image.asset(
                            'assets/images/label.png',
                            width: 25.px,
                            height: 25.px,
                          )),
                    ],
                  )),
                  SizedBox(width: 10),
                  IconButton(
                      onPressed: () async {
                        openFilePicker();
                      },
                      icon: Image.asset(
                        'assets/images/photo_album.png',
                        width: 25.px,
                        height: 25.px,
                      ))
                ],
              ),
            )
          ],
        ));
  }

  openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg']);

    if (result != null) {
      List<String> files =
          result.paths.where((path) => path != null).cast<String>().toList();
      for (String path in files) {
        imageData.add(path);
      }
      setState(() {});
    } else {
      // User canceled the picker
    }
  }
}
