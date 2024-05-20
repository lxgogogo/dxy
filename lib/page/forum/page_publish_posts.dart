import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/forum/page_ait_user.dart';
import 'package:holdem/page/forum/page_select_label.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_info.dart';
import '../../model/upload_file.dart';
import '../../utils/app_theme.dart';
import '../../utils/net_request.dart';
import '../../widget/label_view.dart';

class PublishPostsPage extends StatefulWidget {
  List<BoardInfo> boardInfoList;

  PublishPostsPage({super.key, required this.boardInfoList});

  @override
  State<PublishPostsPage> createState() => _PublishPostsPageState();
}

class _PublishPostsPageState extends State<PublishPostsPage>
    with SingleTickerProviderStateMixin {
  // late int currentBoardId; //所属板块id
  late List<BoardInfo> boardInfoList;
  List<String> items = [];

  final TextEditingController controllerTitle = TextEditingController();
  final _controller = DetectableTextEditingController(
    regExp: detectionRegExp(),
  );

  final customLabelList = <String>[];
  final imageData = []; //选择相册返回的本地地址集合
  final imageUrlList = <UploadFile>[]; //发布提交是的图片地址集合
  final aitList = <int>[];
  final aitUserBeanList = <UserProfile>[]; //@返回的所有用户集合，

  String aitUserContent = ''; //@用户的内容
  bool _isMounted = false;
  String _counter = 'video';
  String? selectedBoardValue;

  late VideoPlayerController _playController;
  late Future<void> _initializeVideoPlayerFuture;
  bool isShowVideoView = false;

  bool _isPlaying = false;
  String? removeAitContentInputText; // 输入框文本 去掉@用户的内容，剩余的正常输入的文本

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    boardInfoList = widget.boardInfoList;
    _controller.addListener(() {});
    boardInfoList.forEach((element) {
      print("publish post board ==${element.name}");
      items.add(element.name!);
    });

    _playController = VideoPlayerController.network('');
    _initializeVideoPlayerFuture = _playController.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
    _playController.dispose();
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              margin: EdgeInsets.fromLTRB(20.px, 0, 10.px, 0),
              // height: 45.px,
              child: TextFormField(
                  style: AppTheme.text000000Size16W500,
                  maxLength: 30,
                  controller: controllerTitle,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 3), // 调整文本位置
                    hintText: '起个标题吧',
                    counterText: '',
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
            )),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  '选择板块',
                  style: AppTheme.text666666Size15,
                ),
                items: items
                    .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: AppTheme.text333333Size15,
                          ),
                        ))
                    .toList(),
                value: selectedBoardValue,
                onChanged: (String? value) {
                  setState(() {
                    selectedBoardValue = value;
                  });
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 120,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10.px, 5.px, 10.px, 0),
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
        Container(
            padding: EdgeInsets.fromLTRB(18.px, 0, 18.px, 0),
            child: Text(
              '单个视频或者最多9张图片',
              style: AppTheme.text999999Size11,
            )),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
            child: _mediaShowView(),
          ),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.fromLTRB(14.px, 6.px, 14.px, 0),
                child: LabelView(
                  isEditLabel: true,
                  labelData: customLabelList,
                  onItemTap: (labelValue) {},
                )))
      ],
    );
  }

  Widget imageGridView() {
    return ReorderableGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      dragEnabled: false,
      dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
            return child;
          }),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final element = imageData.removeAt(oldIndex);
          imageData.insert(newIndex, element);
        });
      },
      footer: [
        imageData.length == 9
            ? Container()
            : IconButton(
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
      children: imageData.map((e) => kIsWeb?buildWebItem(e):buildItem("$e")).toList(),
    );
  }

  Widget buildWebItem(file){
    return Center(
        key: ValueKey(file.name),
        child: Stack(
          children: [
            GestureDetector(
              child: Image.memory(
                Uint8List.fromList(file.bytes),
                width: 98,
                height: 98,
                fit: BoxFit.cover,
              ),
              onTap: () {},
            ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      // imageData.remove(text);
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

  Widget buildItem(String text) {
    return Center(
        key: ValueKey(text),
        child: Stack(
          children: [
            GestureDetector(
              child: Image.file(
                File(text),
                width: 98,
                height: 98,
                fit: BoxFit.cover,
              ),
              onTap: () {},
            ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                  onPressed: () {
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

  Future<void> _pickAndPlayVideo(videoPath) async {
    if (videoPath != null) {
      _playController = VideoPlayerController.file(File(videoPath));
      await _playController.initialize();
      _playController.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  double calculateVideoPlayerWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double videoAspectRatio = _playController.value.aspectRatio;
    return screenWidth / videoAspectRatio;
  }

  Widget _mediaShowView() {
    if (isShowVideoView) {
      return Container(
          padding: EdgeInsets.fromLTRB(16.px, 16.px, 16.px, 0),
          height: 300.px,
          width: calculateVideoPlayerWidth(context),
          child: Stack(alignment: Alignment.center, children: [
            _playController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: _playController.value.size.width,
                      height: _playController.value.size.height,
                      child: VideoPlayer(_playController),
                    ),
                  )
                : Container(),
            _isPlaying
                ? SizedBox.shrink()
                : IconButton(
                    icon: Icon(Icons.play_arrow),
                    iconSize: 64,
                    onPressed: () {
                      _pickAndPlayVideo(imageData[0]);
                    },
                  ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      imageData.clear();
                      isShowVideoView = false;
                    });
                  },
                  icon: Image.asset(
                    'assets/images/close_black.png',
                    width: 25.px,
                    height: 25.px,
                  )),
            )
          ]));
    } else {
      return imageGridView();
    }

    // if (path.isNotEmpty && path.endsWith('mp4')) {
    //   // if (_isMounted) {
    //   //   setState(() {
    //   //     videoFileUrl = path;
    //   //   });
    //   // }
    //   _playController = VideoPlayerController.file(
    //     File(path), // 替换为您的视频 URL
    //   );
    //   _initializeVideoPlayerFuture = _playController.initialize();
    //   return GestureDetector(
    //     onTap: () {
    //       _pickAndPlayVideo(path);
    //     },
    //     child: FutureBuilder(
    //     future: _initializeVideoPlayerFuture,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return AspectRatio(
    //           aspectRatio: _playController.value.aspectRatio,
    //           child: VideoPlayer(_playController),
    //         );
    //       } else {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //     },
    //   ),);
    // } else {
    //   return GestureDetector(
    //     child: Image.file(
    //       File(path),
    //       width: 98,
    //       height: 98,
    //       fit: BoxFit.cover,
    //     ),
    //     onTap: () {},
    //   );
    // }
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
                              aitUserBeanList.add(result);
                              var nickname = result.nickname;
                              var userId = result.id;
                              setState(() {
                                String originalContent = _controller.text;
                                _controller.text =
                                    '@${nickname} $originalContent';
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
                            if (customLabelList != null &&
                                customLabelList.length == 3) {
                              ToastUtils.showToast('最多选择3个标签');
                              return;
                            }
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectLabelPage(
                                        selectedLabelList: customLabelList,
                                      )),
                            );
                            // 在这里处理从ResultPage返回的标签主体
                            if (result != null) {
                              if (_isMounted) {
                                setState(() {
                                  customLabelList.add(result);
                                  customLabelList.forEach((element) {
                                    print('object=====>$element');
                                  });
                                });
                              }
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
                        if (!isCanOpenPicker()) {
                          ToastUtils.showToast('单个视频或者最多9张图片');
                          return;
                        }
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
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4']);

    if (result != null) {
      if (kIsWeb) {
        var files = result.files;
        if (files.length > 9 || files.length + imageData.length > 9) {
          ToastUtils.showToast('单个视频或者最多9张图片');
          return;
        }
        if (files.length > 1) {
          for (var file in files) {
            if (file.extension == 'mp4'||file.extension == 'mov') {
              ToastUtils.showToast('单个视频或者最多9张图片');
              return;
            }
          }
        }

        for (var file in files) {
          imageData.add(file);
        }

        setState(() {
        if (imageData.isNotEmpty &&
            imageData.length == 1 &&
            imageData[0].extension == 'mp4') {
          isShowVideoView = true;
        } else {
          isShowVideoView = false;
        }
      });
        return;
      }
      List<String> files =
          result.paths.where((path) => path != null).cast<String>().toList();
      if (result.files.length > 9 ||
          result.files.length + imageData.length > 9) {
        ToastUtils.showToast('单个视频或者最多9张图片');
        return;
      }

      if (files.length > 1) {
        for (String path in files) {
          if (path.endsWith('mp4')) {
            ToastUtils.showToast('单个视频或者最多9张图片');
            return;
          }
        }
      }

      for (String path in files) {
        print('FilePickerResult: ' + path);
        imageData.add(path);
      }
      setState(() {
        if (imageData.isNotEmpty &&
            imageData.length == 1 &&
            imageData[0].endsWith('mp4')) {
          isShowVideoView = true;
        } else {
          isShowVideoView = false;
        }
      });
    } else {
      // User canceled the picker
    }
  }

  bool isCanOpenPicker() {
    if (isShowVideoView) {
      return false;
    }
    if (imageData.length == 9) {
      return false;
    }
    return true;
  }

  ///板块id
  int _getBoardIdByName() {
    if (selectedBoardValue!.isNotEmpty) {
      for (BoardInfo boardInfo in boardInfoList) {
        if (boardInfo.name == selectedBoardValue) {
          return boardInfo.id!;
        }
      }
    }
    return -1;
  }

  void _aitUserData() {
    String content = _controller.text;
    Iterable<Match> matches = atSignRegExp.allMatches(content); // 获取所有匹配项
    List<String> containsAitStrList = []; // 包含@符号的文本
    List<String> splitNameList = []; // 分割@符号的后存放用户名称

    for (Match match in matches) {
      print('Found=====================: ${match.group(0)}'); // 输出匹配到
      var matchStr = match.group(0);
      containsAitStrList.add(matchStr!);
    }
    if (containsAitStrList.isNotEmpty && containsAitStrList.length > 0) {
      for (String aitStr in containsAitStrList) {
        content = content.replaceAll(aitStr, "");
        List<String> aitStrList = aitStr.split('@');
        splitNameList.add(aitStrList[1]);
      }
    }

    print('final input text:${content}');
    removeAitContentInputText = content; //最终的帖子内容文本

    //循环名称list获取所有@用户信息
    if (splitNameList.isNotEmpty && splitNameList.length > 0) {
      for (String userName in splitNameList) {
        for (UserProfile userProfile in aitUserBeanList) {
          if (userName == userProfile.nickname) {
            aitList.add(userProfile.id!); //@用户的id集合
          }
        }
      }
    }
  }

  ///先上传文件，文件上传完，提交发布帖子
  void publishPosts() {
    _aitUserData();

    String title = controllerTitle.text;
    String content = removeAitContentInputText!;

    if (imageUrlList.isNotEmpty) {
      imageUrlList.clear();
    }

    if (_getBoardIdByName == -1) {
      ToastUtils.showToast('请选择发帖板块');
      return;
    }

    if (title.isEmpty || title.length < 5) {
      ToastUtils.showToast('请输入5-30个字符标题');
      return;
    }

    if (content.isEmpty) {
      ToastUtils.showToast('内容不能为空');
      return;
    }

    imageData.forEach((element) async {
      if (kIsWeb){
        NetRequest().uploadBytesFile(element, (data) {
          UploadFile uploadFile = UploadFile.fromJson(data);
          print('uploadFile url===' + uploadFile.url!);
          imageUrlList.add(uploadFile);

          print('uploadFile url===${imageUrlList.length}' +
              'imageData|==>${imageData.length}');

          if (imageUrlList.isNotEmpty &&
              imageUrlList.length == imageData.length) {
            NetRequest().threadCreate(title, content, _getBoardIdByName(),
                customLabelList, imageUrlList, aitList, (data) {
              Navigator.pop(context);
            });
          }
        });
        return;
      }
      NetRequest().uploadFile(element, (data) {
        UploadFile uploadFile = UploadFile.fromJson(data);
        print('uploadFile url===' + uploadFile.url!);
        imageUrlList.add(uploadFile);

        print('uploadFile url===${imageUrlList.length}' +
            'imageData|==>${imageData.length}');

        if (imageUrlList.isNotEmpty &&
            imageUrlList.length == imageData.length) {
          NetRequest().threadCreate(title, content, _getBoardIdByName(),
              customLabelList, imageUrlList, aitList, (data) {
            Navigator.pop(context);
          });
        }
      });
    });
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
    final Match match = userAtMentionRegex
        .firstMatch(text.substring(0, selectionIndex)) as Match;

    if (match != null && match.start == selectionIndex - match[0]!.length) {
      // 如果匹配到'@用户名'且光标正好在用户名之后，则删除整个'@用户名'
      _controller.text = text.substring(0, selectionIndex - match[0]!.length);
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    } else {
      // 否则正常处理文本变化
      // 这里不需要做任何操作，因为TextField会自动处理文本变化
    }
  }
}
