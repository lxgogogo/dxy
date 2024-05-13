import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:holdem/page/forum/page_ait_user.dart';
import 'package:holdem/page/forum/page_select_label.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../model/upload_file.dart';
import '../../utils/app_theme.dart';
import '../../utils/net_request.dart';
import '../../widget/label_view.dart';

class PublishPostsPage extends StatefulWidget {
  int currentBoardId;

  PublishPostsPage({super.key, required this.currentBoardId});

  @override
  State<PublishPostsPage> createState() => _PublishPostsPageState();
}

class _PublishPostsPageState extends State<PublishPostsPage>
    with SingleTickerProviderStateMixin {
  late int currentBoardId; //所属板块id

  final TextEditingController controllerTitle = TextEditingController();
  final _controller = DetectableTextEditingController(
    regExp: detectionRegExp(),
  );

  final customLabel = <String>[];
  final imageData = <String>[]; //选择相册返回的本地地址集合
  final imageUrlList= <UploadFile>[]; //发布提交是的图片地址集合
  final aitList = <int>[];

  String aitUserContent = ''; //@用户的内容

  @override
  void initState() {
    super.initState();
    currentBoardId = widget.currentBoardId;
    print("publish post board id ==$currentBoardId");
    _controller.addListener(() {

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
                publishPosts();
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
              controller: _controller,
              onChanged: (text) {
                _handleTextChange();
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
                                String originalContent = _controller.text;
                                _controller.text =
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
                              if(customLabel!= null && customLabel.length == 3) {
                                ToastUtils.showToast('最多选择3个标签');
                                result;
                              }
                              setState(() {
                                customLabel.add(result);
                                customLabel.forEach((element) {
                                  print('object=====>$element');
                                });
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
      if (result.files.length > 9) {
        ToastUtils.showToast('最多可选择9个文件');
        return;
      } else {
        for (String path in files) {
          imageData.add(path);
        }
        setState(() {});
      }

    } else {
      // User canceled the picker
    }
  }

  ///先上传文件，文件上传完，提交发布帖子
  void publishPosts() {
    String title = controllerTitle.text;
    String content = _controller.text;

    if (title.isEmpty) {
      ToastUtils.showToast('标题不能为空');
      return;
    }
    if (content.isEmpty) {
      ToastUtils.showToast('内容不能为空');
      return;
    }

    Iterable<Match> matches = atSignRegExp.allMatches(content); // 获取所有匹配项

    for (Match match in matches) {
      print('🌶Tap: $match');
      print('Found: ${match.group(0)}'); // 输出匹配到的数字
    }

    imageData.forEach((element) async {
      // XFile? compressedImage = await compressAndGetFile(File(element),element);
      // print('uploadFile path==='  + compressedImage!.path);
      NetRequest().uploadFile(element, (data) {
          UploadFile uploadFile = UploadFile.fromJson(data);
          print('uploadFile url==='  + uploadFile.url!);
          imageUrlList.add(uploadFile);
      });
    });

    if (imageUrlList != null && imageUrlList.length == imageData.length) {
      NetRequest().threadCreate(title, content,
          currentBoardId, customLabel, imageUrlList, aitList, (data) {
            Navigator.pop(context);
          });
    }
  }

  // Future<XFile?> compressAndGetFile(File file, String targetPath) async {
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path, targetPath,
  //     quality: 50,
  //     rotate: 180,
  //   );
  //   return result;
  // }

  void _handleTextChange() {
    String text = _controller.text.toString();
    // 获取当前光标位置
    final int selectionIndex = _controller.selection.baseOffset;

    // 检查前一个字符是否为'@'且当前字符位置之前是否存在以空格或者文本开头结束的人名
    final RegExp userAtMentionRegex = RegExp(r'(@\S+)\s*$');
    final Match match = userAtMentionRegex.firstMatch(text.substring(0, selectionIndex)) as Match;

    if (match != null && match.start == selectionIndex - match[0]!.length) {
      // 如果匹配到'@用户名'且光标正好在用户名之后，则删除整个'@用户名'
      _controller.text = text.substring(0, selectionIndex - match[0]!.length);
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    } else {
      // 否则正常处理文本变化
      // 这里不需要做任何操作，因为TextField会自动处理文本变化
    }
  }
}
