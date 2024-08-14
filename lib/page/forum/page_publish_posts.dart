import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/forum/page_ait_user.dart';
import 'package:holdem/page/forum/page_select_label.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:video_player/video_player.dart';

import '../../model/board_info.dart';
import '../../model/upload_file.dart';
import '../../utils/app_theme.dart';
import '../../utils/common_utils.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import '../../widget/MyDropdownButton.dart';
import '../../widget/label_view.dart';
import '../../widget/page_web_fit.dart';

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
  int uploadProgress = 0;

  late VideoPlayerController _playController;
  late Future<void> _initializeVideoPlayerFuture;
  bool isShowVideoView = false;

  // Uint8List? videoImageBytes;

  bool _isPlaying = false;
  String? removeAitContentInputText; // 输入框文本 去掉@用户的内容，剩余的正常输入的文本

  bool isClickPublish = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    boardInfoList = widget.boardInfoList;
    _controller.addListener(() {});
    boardInfoList.forEach((element) {
      print("publish post board ==${element.name}");
      items.add(element.name!);
      selectedBoardValue = items[0];
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
    if (isShowVideoView) {
      if (_playController.value.isInitialized) {
        _playController.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          '发帖',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        // bottom: const PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Divider(
        //     color: AppTheme.color_F3F3F3,
        //     thickness: 1,
        //   ),
        // ),
        actions: [
          GestureDetector(
            onTap: () {
              if (isClickPublish) {
                return;
              }
              var debouncer = CommonUtils.getDebouncer('publishPosts');
              debouncer.run(() {
                publishPosts();
              });
            },
            child: Container(
              width: 50.px,
              height: 24.px,
              margin: EdgeInsets.only(right: 10.px),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/publish2.png'),
                      fit: BoxFit.cover)),
              child: Text(
                '发布',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
          // IconButton(
          //     hoverColor: Colors.transparent,
          //     highlightColor: Colors.transparent,
          //     onPressed: () {
          //       if (isClickPublish) {
          //         return;
          //       }
          //       var debouncer = CommonUtils.getDebouncer('publishPosts');
          //       debouncer.run(() {
          //         publishPosts();
          //       });
          //     },
          //     icon: Image.asset(
          //       'assets/images/release.png',
          //       width: 50.px,
          //       height: 29.px,
          //     ))
        ],
      ),
      body: SafeArea(
          child: Container(
              // color: Colors.red,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF4F7FC),
                  Color(0xFFE4EEF9),
                  Color(0xFFE4EEF9)
                ],
              )),
              child: contentView())),
      bottomSheet: bottomView(),
    ));
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
                  style: AppTheme.text333333Size16,
                  maxLength: 30,
                  controller: controllerTitle,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                    // 调整文本位置
                    hintText: '请输入完整帖子标题（5-31个字）',
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
                    fillColor: Colors.transparent,
                  )),
            )),
            Container(
                width: 110.px,
                alignment: Alignment.center,
                child: MyDropdownButton(
                    items: items,
                    onChanged: (value) {
                      selectedBoardValue = value; //选择板块
                    }))
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10.px, 5.px, 10.px, 0),
          height: 150.px,
          child: DetectableTextField(
              maxLines: 5,
              style: AppTheme.text333333Size16,
              controller: _controller,
              onChanged: (text) {
                _handleTextChange();
              },
              decoration: const InputDecoration(
                hintText: '请输入正文（建议200-2000字）',
                hintStyle: AppTheme.text999999Size16,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              )),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(18.px, 0, 18.px, 0),
            child: Text(
              '单个视频或者最多9张图片',
              style: AppTheme.text999999Size11,
            )),
        Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
              child: _mediaShowView(),
            ),
          )
        ]),
        Row(
          children: [
            Expanded(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(14.px, 6.px, 14.px, 0),
                    child: LabelView(
                      isEditLabel: true,
                      labelData: customLabelList,
                      onItemTap: (labelValue) {},
                      onDelTap: (value) {
                        if (_isMounted) {
                          setState(() {
                            print('==========value=============${value}');
                            customLabelList.remove(value);
                          });
                        }
                      },
                    )))
          ],
        ),
        Visibility(
            visible: imageData.length >= 6 ? true : false,
            child: SizedBox(
              height: 120.px,
            ))
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
        if (_isMounted) {
          setState(() {
            final element = imageData.removeAt(oldIndex);
            imageData.insert(newIndex, element);
          });
        }
      },
      footer: imageData.length == 9
          ? []
          : [
              IconButton(
                  onPressed: () {
                    openFilePicker();
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Image.asset(
                    'assets/images/image_add.png',
                    width: 111,
                    height: 111,
                    fit: BoxFit.cover,
                  )),
            ],
      children: imageData
          .map((e) => kIsWeb ? buildWebItem(e) : buildItem("$e"))
          .toList(),
    );
  }

  Widget buildWebItem(file) {
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
                    if (_isMounted) {
                      setState(() {
                        imageData.remove(file);
                      });
                    }
                  },
                  icon: Image.asset(
                    'assets/images/close_black.png',
                    width: 12.px,
                    height: 12.px,
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
                    if (_isMounted) {
                      setState(() {
                        imageData.remove(text);
                      });
                    }
                  },
                  icon: Image.asset(
                    'assets/images/close_black.png',
                    width: 12.px,
                    height: 12.px,
                  )),
            )
          ],
        ));
  }

  Future<void> _pickAndPlayVideo(videoPath) async {
    if (videoPath != null) {
      // _playController = VideoPlayerController.file(File(videoPath));
      _playController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      await _playController.initialize();
      _playController.play();
      if (_isMounted) {
        setState(() {
          _isPlaying = true;
        });
      }
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
          width: 120,
          height: 180,
          child: Stack(alignment: Alignment.center, children: [
            // if (videoImageBytes != null)
            //   Image.memory(videoImageBytes!,
            //       width: 120,
            //       height: 180,
            //       fit: BoxFit.cover),
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
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        imageUrlList[0].posterUrl!,
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/images/play_btn.png',
                          width: 35.px,
                          height: 35.px,
                        ),
                        onPressed: () {
                          _pickAndPlayVideo(imageUrlList[0].url);
                        },
                      ),
                    ],
                  ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                  onPressed: () {
                    if (_isMounted) {
                      setState(() {
                        imageData.clear();
                        imageUrlList.clear();
                        _playController.dispose();
                        _isPlaying = false;
                        isShowVideoView = false;
                        uploadProgress = 0;
                      });
                    }
                  },
                  icon: Image.asset(
                    'assets/images/close_black.png',
                    width: 12.px,
                    height: 12.px,
                  )),
            )
          ]));

      // _playController = VideoPlayerController.network('');
      // _initializeVideoPlayerFuture = _playController.initialize().then((_) {
      //   // Ensure the first frame is shown after the video is initialized
      //   setState(() {});
      // });
      // return Container(
      //     padding: EdgeInsets.fromLTRB(16.px, 16.px, 16.px, 0),
      //     height: 300.px,
      //     width: calculateVideoPlayerWidth(context),
      //     child: Stack(alignment: Alignment.center, children: [
      //       _playController.value.isInitialized
      //           ? FittedBox(
      //               fit: BoxFit.fitHeight,
      //               child: SizedBox(
      //                 width: _playController.value.size.width,
      //                 height: _playController.value.size.height,
      //                 child: VideoPlayer(_playController),
      //               ),
      //             )
      //           : Container(),
      //       _isPlaying
      //           ? SizedBox.shrink()
      //           : IconButton(
      //               icon: Icon(Icons.play_arrow),
      //               iconSize: 64,
      //               onPressed: () {
      //                 _pickAndPlayVideo(imageData[0]);
      //               },
      //             ),
      //       Positioned(
      //         right: -10,
      //         top: -10,
      //         child: IconButton(
      //             onPressed: () {
      //               setState(() {
      //                 imageData.clear();
      //                 isShowVideoView = false;
      //               });
      //             },
      //             icon: Image.asset(
      //               'assets/images/close_black.png',
      //               width: 25.px,
      //               height: 25.px,
      //             )),
      //       )
      //     ]));
    } else {
      return imageGridView();
    }
  }

  Widget bottomView() {
    return Container(
        height: 46.px,
        color: const Color(0xffE4EEF9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              height: 0.5,
              color: AppTheme.color_F3F3F3,
            ),
            Container(
              height: 45.px,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      SizedBox(
                        width: 5.px,
                      ),
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
                            width: 22.px,
                            height: 22.px,
                          )),
                      SizedBox(
                        width: 5.px,
                      ),
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
                              if (_isMounted) {
                                setState(() {
                                  String originalContent = _controller.text;
                                  _controller.text =
                                      '@${nickname} $originalContent';
                                  print('forumLog=====' + aitUserContent);
                                });
                              }
                            }
                          },
                          icon: Image.asset(
                            'assets/images/ait.png',
                            width: 22.px,
                            height: 22.px,
                          )),
                      SizedBox(
                        width: 5.px,
                      ),
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
                            width: 22.px,
                            height: 22.px,
                          )),
                    ],
                  )),
                  SizedBox(width: 10),
                ],
              ),
            )
          ],
        ));
  }

  openFilePicker() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov']);
      if (result != null) {
        var files = result.files;
        var filesBytes = result.files.first.bytes;
        if (files.length > 9 || files.length + imageData.length > 9) {
          ToastUtils.showToast('单个视频或者最多9张图片');
          return;
        }
        if (files.length > 1) {
          for (var file in files) {
            if (file.extension == 'mp4' || file.extension == 'mov') {
              ToastUtils.showToast('单个视频或者最多9张图片');
              return;
            }
          }
        }

        for (var file in files) {
          imageData.add(file);
        }

        if (imageData.isNotEmpty &&
            imageData.length == 1 &&
            (imageData[0].extension == 'mp4' ||
                imageData[0].extension == 'mov')) {
          //byte 处理目前不好用
          // final blob = html.Blob([imageData[0].bytes]);
          // final url = html.Url.createObjectUrlFromBlob(blob);
          // final uint8list = await VideoThumbnail.thumbnailData(
          //   video: '',
          //   imageFormat: ImageFormat.JPEG,
          //   maxWidth: 128,
          //   // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          //   quality: 25,
          // );
          // setState(() {
          //   isShowVideoView = true;
          //   videoImageBytes = uint8list;
          // });

          //
          EasyLoading.showProgress(uploadProgress.toDouble(),
              status: '视频处理中...${uploadProgress}%');
          NetRequest().uploadBytesFile(
            imageData[0],
            (data) {
              UploadFile uploadFile = UploadFile.fromJson(data);
              EasyLoading.dismiss();
              _playController =
                  VideoPlayerController.networkUrl(Uri.parse(uploadFile.url!));
              setState(() {
                imageUrlList.add(uploadFile);
                isShowVideoView = true;
                // videoImageBytes = uint8list;
              });
            },
            (errMsg) {
              EasyLoading.dismiss();
              ToastUtils.showToast('上传文件失败，请重新上传');
            },
            (int sent, int total) {
              // setState(() {
              uploadProgress = ((sent / total) * 100).round();
              if (uploadProgress == 100) {
                uploadProgress = 99;
              }
              EasyLoading.showProgress((uploadProgress / 100).toDouble(),
                  status: '视频处理中...${uploadProgress}%');
              // });
            },
          );
        } else {
          setState(() {
            isShowVideoView = false;
          });
        }
      }
      // ///////////////////////////////////////app///////////////////////////////////////////
      // List<String> files =
      //     result.paths.where((path) => path != null).cast<String>().toList();
      // if (result.files.length > 9 ||
      //     result.files.length + imageData.length > 9) {
      //   ToastUtils.showToast('单个视频或者最多9张图片');
      //   return;
      // }
      //
      // if (files.length > 1) {
      //   for (String path in files) {
      //     if (path.endsWith('mp4') || path.endsWith('mov')) {
      //       ToastUtils.showToast('单个视频或者最多9张图片');
      //       return;
      //     }
      //   }
      // }
      //
      // for (String path in files) {
      //   print('FilePickerResult: ' + path);
      //   imageData.add(path);
      // }
      //
      // if (imageData.isNotEmpty &&
      //     imageData.length == 1 &&
      //     (imageData[0].endsWith('mp4') || imageData[0].endsWith('mov'))) {
      //   //byte 处理目前不好用
      //   // final uint8list = await VideoThumbnail.thumbnailData(
      //   //   video: imageData[0],
      //   //   imageFormat: ImageFormat.JPEG,
      //   //   maxWidth: 128,
      //   //   // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      //   //   quality: 100,
      //   // );
      //   // setState(() {
      //   //   isShowVideoView = true;
      //   //   videoImageBytes = uint8list;
      //   // });
      //
      //   EasyLoading.show(status: 'loading...');
      //   NetRequest().uploadBytesFile(imageData[0], (data) {
      //     UploadFile uploadFile = UploadFile.fromJson(data);
      //     EasyLoading.dismiss();
      //     _playController = VideoPlayerController.networkUrl(Uri.parse(uploadFile.url!));
      //     setState(() {
      //       imageUrlList.add(uploadFile);
      //       isShowVideoView = true;
      //     });
      //   }, (errMsg) {
      //     EasyLoading.dismiss();
      //   });
      //
      // } else {
      //   setState(() {
      //     isShowVideoView = false;
      //   });
      // }
    } else {
      // ios or Android

      final ImagePicker picker = ImagePicker();
      final List<XFile> files = await picker.pickMultipleMedia(limit: 9);
      // final XFile? media =  await picker.pickImage(source: ImageSource.gallery);
      // List<XFile> files = [];
      if (files.length > 9 || files.length + imageData.length > 9) {
        ToastUtils.showToast('单个视频或者最多9张图片');
        return;
      }
      if (files.length > 1) {
        for (var file in files) {
          if (file.path.endsWith('mp4') || file.path.endsWith('mov')) {
            ToastUtils.showToast('单个视频或者最多9张图片');
            return;
          }
        }
      }

      //手机端都放文件 path
      for (var file in files) {
        print('===========ios or Android==============${file.path}');
        imageData.add(file.path);
      }

      if (imageData.isNotEmpty &&
          imageData.length == 1 &&
          (imageData[0].endsWith('mp4') || imageData[0].endsWith('mov'))) {
        EasyLoading.showProgress(uploadProgress.toDouble(),
            status: '视频处理中...${uploadProgress}%');
        var count = 0;
        NetRequest().uploadFile(
          imageData[0],
          (data) {
            UploadFile uploadFile = UploadFile.fromJson(data);
            EasyLoading.dismiss();
            _playController =
                VideoPlayerController.networkUrl(Uri.parse(uploadFile.url!));
            setState(() {
              imageUrlList.add(uploadFile);
              isShowVideoView = true;
              // videoImageBytes = uint8list;
            });
          },
          (errMsg) {
            EasyLoading.dismiss();
            ToastUtils.showToast('上传文件失败，请重新上传');
            _uploadMediaFail();
          },
          (int sent, int total) {
            // setState(() {
            uploadProgress = ((sent / total) * 100).round();
            if (uploadProgress == 100) {
              uploadProgress = 99;
            }
            EasyLoading.showProgress((uploadProgress / 100).toDouble(),
                status: '视频处理中...${uploadProgress}%');
            // });
          },
        );
      } else {
        if (_isMounted) {
          setState(() {
            isShowVideoView = false;
          });
        }
      }
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
    if (selectedBoardValue != null && selectedBoardValue!.isNotEmpty) {
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
    // removeAitContentInputText = content; //最终的帖子内容文本

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
    // String content = removeAitContentInputText!;
    String content = _controller.text;

    if (!isShowVideoView && imageUrlList.isNotEmpty) {
      imageUrlList.clear();
    }

    if (_getBoardIdByName() == -1) {
      ToastUtils.showToast('请选择发帖板块');
      return;
    }

    if (title.isEmpty || title.length < 5) {
      ToastUtils.showToast('请输入5-30个字符标题');
      return;
    }

    if (content.isEmpty || content.length < 10) {
      ToastUtils.showToast('帖子内容长度不能小于10个字符');
      return;
    }
    isClickPublish = true; //发布按钮触发
    EasyLoading.show(status: 'loading...');

    //视频类型：不需要上传文件，直接取视频的path数据上传
    if (isShowVideoView) {
      NetRequest().threadCreate(title, content, _getBoardIdByName(),
          customLabelList, imageUrlList, aitList, (data) {
        //通知刷新论坛列表
        EventBusManager.eventBus
            .fire(EventBusAction.refreshForumList.eventBusTypeName);
        EasyLoading.dismiss();
        Navigator.pop(context);
      }, (errMsg) {
        isClickPublish = false;
      });
    } else {
      //图片类型：
      if (imageData.isNotEmpty) {
        //有图
        imageData.forEach((element) async {
          if (kIsWeb) {
            var fileData = element;
            print(
                '=======kIsWeb=======${element.size} // isDebugMode==${kDebugMode}');

            try {
              //对图片进行压缩处理
              var result = await FlutterImageCompress.compressWithList(
                Uint8List.fromList(element.bytes),
                minHeight: 1920,
                minWidth: 1080,
                quality: 50,
              );
              print('=======kIsWeb=22222222222======${result.lengthInBytes}');
              var pFile = PlatformFile(
                  name: element.name, bytes: result, size: result.length);
              fileData = pFile;
            } catch (e) {
              print('发布模式压缩图片发生错误：$e');
              fileData = element;
            }

            //正式上传 web这里是个 PlatformFile
            NetRequest().uploadBytesFile(fileData, (data) {
              UploadFile uploadFile = UploadFile.fromJson(data);
              imageUrlList.add(uploadFile);

              if (imageUrlList.isNotEmpty &&
                  imageUrlList.length == imageData.length) {
                NetRequest().threadCreate(title, content, _getBoardIdByName(),
                    customLabelList, imageUrlList, aitList, (data) {
                  //通知刷新论坛列表
                  EventBusManager.eventBus
                      .fire(EventBusAction.refreshForumList.eventBusTypeName);
                  EasyLoading.dismiss();
                  Navigator.pop(context);
                }, (errMsg) {
                  isClickPublish = false;
                });
              }
            }, (errMsg) {
              //上传文件失败
              EasyLoading.dismiss();
              ToastUtils.showToast('上传文件失败，请重新上传');
              _uploadMediaFail();
            }, (int sent, int total) {});
          } else {
            //手机端
            // 获取应用的临时目录作为输出路径
            final Directory tempDir = await getTemporaryDirectory();
            String tempPath = '${tempDir.path}/image.jpg';
            print('ios or android image tempPath=====>${tempPath}');
            //对图片进行压缩处理
            var result = await FlutterImageCompress.compressAndGetFile(
              element, tempPath,
              // format: _getCompressFormat(element),
              quality: 50,
            );
            //正式上传 app这里是个 filePath
            NetRequest().uploadFile(result!.path, (data) {
              UploadFile uploadFile = UploadFile.fromJson(data);
              imageUrlList.add(uploadFile);
              if (imageUrlList.isNotEmpty &&
                  imageUrlList.length == imageData.length) {
                NetRequest().threadCreate(title, content, _getBoardIdByName(),
                    customLabelList, imageUrlList, aitList, (data) {
                  //通知刷新论坛列表
                  EventBusManager.eventBus
                      .fire(EventBusAction.refreshForumList.eventBusTypeName);
                  EasyLoading.dismiss();
                  Navigator.pop(context);
                }, (errMsg) {
                  isClickPublish = false;
                });
              }
            }, (errMsg) {
              //上传文件失败
              EasyLoading.dismiss();
              ToastUtils.showToast('上传文件失败，请重新上传');
              _uploadMediaFail();
            }, (int sent, int total) {});
          }
        });
      } else {
        //无图
        //没有图片视频直接上传
        NetRequest().threadCreate(title, content, _getBoardIdByName(),
            customLabelList, imageUrlList, aitList, (data) {
          //通知刷新论坛列表
          EventBusManager.eventBus
              .fire(EventBusAction.refreshForumList.eventBusTypeName);
          EasyLoading.dismiss();
          Navigator.pop(context);
        }, (errMsg) {
          isClickPublish = false;
        });
      }
    }
  }

  _getCompressFormat(var path) {
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return CompressFormat.jpeg;
    } else if (path.endsWith('.png')) {
      return CompressFormat.png;
    } else if (path.endsWith('.webp')) {
      return CompressFormat.webp;
    }
  }

  ///上传文件失败
  _uploadMediaFail() {
    if (_isMounted) {
      setState(() {
        imageUrlList.clear();
        uploadProgress = 0;
        isClickPublish = false;
      });
    }
  }

  void _handleTextChange() {
    String text = _controller.text.toString();
    // 获取当前光标位置
    final int selectionIndex = _controller.selection.baseOffset;

    // 检查前一个字符是否为'@'且当前字符位置之前是否存在以空格或者文本开头结束的人名
    final RegExp userAtMentionRegex = RegExp(r'(@\S+)\s*$');
    if (userAtMentionRegex.firstMatch(text.substring(0, selectionIndex)) !=
        null) {
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
}
