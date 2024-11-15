import 'dart:io';
import 'dart:math';
import 'dart:ui';

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
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:super_tooltip/super_tooltip.dart';
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
  final List<BoardInfo> boardInfoList;

  const PublishPostsPage({super.key, required this.boardInfoList});

  @override
  State<PublishPostsPage> createState() => _PublishPostsPageState();
}

class _PublishPostsPageState extends State<PublishPostsPage> with SingleTickerProviderStateMixin {
  BoardInfo? get currentBord =>
      _prefixIndex != -1 && _prefixIndex < widget.boardInfoList.length ? widget.boardInfoList[_prefixIndex] : null;
  int _prefixIndex = -1;

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
  int uploadProgress = 0;

  late VideoPlayerController _playController;
  bool isShowVideoView = false;

  bool _isPlaying = false;

  bool isClickPublish = false;

  final _tipController = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
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
    return BackgroundContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
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
                  image: DecorationImage(image: AssetImage('assets/images/publish2.png'), fit: BoxFit.cover)),
              child: Text(
                '发布',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: contentView(),
    ));
  }

  Widget contentView() {
    return Container(
      margin: EdgeInsets.only(top: 12.px),
      padding: EdgeInsets.only(
        bottom: window.viewPadding.bottom / window.devicePixelRatio,
      ),
      decoration: const BoxDecoration(
          color: Color(0xfff2f9ff),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6FBFF),
              Color(0xFFE8F3FF),
            ],
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xffe6e6e6), width: 0.5),
                ),
              ),
              height: 42.5.px,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.px,
                          color: const Color(0xff2a2a2a),
                        ),
                        maxLength: 30,
                        controller: controllerTitle,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.px),
                          hintText: '请输入完整帖子标题（5-31个字）',
                          counterText: '',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.px,
                            color: const Color(0xff2c2c2c).withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          filled: false,
                        )),
                  ),
                  SuperTooltip(
                    showBarrier: true,
                    controller: _tipController,
                    popupDirection: TooltipDirection.down,
                    backgroundColor: Colors.transparent,
                    hasShadow: false,
                    borderColor: Colors.transparent,
                    arrowLength: 0,
                    arrowTipDistance: 21.25.px,
                    bubbleDimensions: EdgeInsets.zero,
                    touchThroughAreaShape: ClipAreaShape.rectangle,
                    touchThroughAreaCornerRadius: 10,
                    minimumOutsideMargin: 0,
                    barrierColor: Colors.transparent,
                    content: Container(
                      width: 90.px,
                      decoration: const BoxDecoration(
                        color: Color(0xfffafcff),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.boardInfoList.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (BuildContext context, int index) {
                          final item = widget.boardInfoList[index];
                          return GestureDetector(
                            onTap: () {
                              _tipController.hideTooltip();
                              if (_prefixIndex != index) {
                                _prefixIndex = index;
                                setState(() {});
                              }
                            },
                            child: Container(
                              height: 41.5.px,
                              alignment: Alignment.center,
                              child: Text(
                                item.name ?? '',
                                style: TextStyle(
                                  color: _prefixIndex == index ? const Color(0xff249cfc) : const Color(0xff95a3c4),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => Container(
                          color: const Color(0xffe7f0fa),
                          height: 0.5,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (widget.boardInfoList.isNotEmpty) {
                          _tipController.showTooltip();
                        }
                      },
                      child: SizedBox(
                        width: 90.px,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _prefixIndex != -1 && _prefixIndex < widget.boardInfoList.length
                                  ? (widget.boardInfoList[_prefixIndex].name ?? '')
                                  : '选择板块',
                              style: const TextStyle(
                                color: Color(0xff2a2a2a),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xff2a2a2a),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150.px,
              child: DetectableTextField(
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 14.px,
                    color: const Color(0xff2a2a2a),
                  ),
                  controller: _controller,
                  onChanged: (text) {
                    // _handleTextChange();
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.px, vertical: 15.5.px),
                    hintText: '请输入正文（建议10-2000字）',
                    hintStyle: TextStyle(
                      fontSize: 14.px,
                      color: const Color(0xff2a2a2a).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    filled: false,
                  )),
            ),
            Text(
              '单个视频或者最多9张图片',
              style: TextStyle(
                fontSize: 12.px,
                color: const Color(0xff2a2a2a).withOpacity(0.5),
              ),
            ),
            _mediaShowView(),
            LabelView(
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
            ),
            Visibility(
                visible: imageData.length >= 6 ? true : false,
                child: SizedBox(
                  height: 120.px,
                )),
            const Spacer(),
            bottomView(),
          ],
        ),
      ),
    );
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
            if (_playController.value.isInitialized)
              FittedBox(
                fit: BoxFit.fitHeight,
                child: SizedBox(
                  width: _playController.value.size.width,
                  height: _playController.value.size.height,
                  child: VideoPlayer(_playController),
                ),
              ),
            if (!_isPlaying)
              Stack(
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
    } else {
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
        children: imageData.map((e) => buildItem("$e")).toList(),
      );
    }
  }

  Widget bottomView() {
    return Container(
      height: 41.5.px,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffe6e6e6))),
      ),
      child: Row(
        children: [
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
                  MaterialPageRoute(builder: (context) => AitUserPage()),
                );
                // 在这里处理从ResultPage返回的结果
                if (result != null) {
                  aitUserBeanList.add(result);
                  var nickname = result.nickname;
                  var userId = result.id;
                  if (_isMounted) {
                    setState(() {
                      String originalContent = _controller.text;
                      _controller.text = '@${nickname} $originalContent';
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
        ],
      ),
    );
  }

  openFilePicker() async {
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
      EasyLoading.showProgress(uploadProgress.toDouble(), status: '视频处理中...${uploadProgress}%');
      var count = 0;
      NetRequest().uploadFile(
        imageData[0],
        (data) {
          UploadFile uploadFile = UploadFile.fromJson(data);
          EasyLoading.dismiss();
          _playController = VideoPlayerController.networkUrl(Uri.parse(uploadFile.url!));
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
          EasyLoading.showProgress((uploadProgress / 100).toDouble(), status: '视频处理中...${uploadProgress}%');
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

  bool isCanOpenPicker() {
    if (isShowVideoView) {
      return false;
    }
    if (imageData.length == 9) {
      return false;
    }
    return true;
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

    if (currentBord == null || currentBord?.id == -1) {
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
      NetRequest().threadCreate(title, content, currentBord!.id!, customLabelList, imageUrlList, aitList, (data) {
        //通知刷新论坛列表
        EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);
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
            if (imageUrlList.isNotEmpty && imageUrlList.length == imageData.length) {
              NetRequest().threadCreate(title, content, currentBord!.id!, customLabelList, imageUrlList, aitList,
                  (data) {
                //通知刷新论坛列表
                EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);
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
        });
      } else {
        //无图
        //没有图片视频直接上传
        NetRequest().threadCreate(title, content, currentBord!.id!, customLabelList, imageUrlList, aitList, (data) {
          //通知刷新论坛列表
          EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);
          EasyLoading.dismiss();
          Navigator.pop(context);
        }, (errMsg) {
          isClickPublish = false;
        });
      }
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
    if (userAtMentionRegex.firstMatch(text.substring(0, selectionIndex)) != null) {
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
}
