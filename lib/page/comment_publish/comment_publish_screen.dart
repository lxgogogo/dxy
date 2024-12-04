import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../model/upload_file.dart';
import '../../utils/app_theme.dart';
import '../../utils/common_utils.dart';
import '../../utils/net_request.dart';

part 'comment_publish_controller.dart';

class CommentPublishScreen extends StatefulWidget {
  final String relType;
  final int relId;

  const CommentPublishScreen({super.key, required this.relType, required this.relId});

  @override
  State<CommentPublishScreen> createState() => _CommentPublishScreenState();
}

class _CommentPublishScreenState extends State<CommentPublishScreen> with SingleTickerProviderStateMixin {
  final _controller = DetectableTextEditingController(
    regExp: detectionRegExp(),
  );

  final imageData = []; //选择相册返回的本地地址集合
  final imageUrlList = <UploadFile>[]; //发布提交是的图片地址集合
  final aitList = <int>[];
  final aitUserBeanList = <UserProfile>[]; //@返回的所有用户集合，

  String aitUserContent = ''; //@用户的内容
  bool _isMounted = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
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
          '评论',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              var debouncer = CommonUtils.getDebouncer('publishComment');
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.px),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2000),
                      ],
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
                  '最多9张图片',
                  style: TextStyle(
                    fontSize: 12.px,
                    color: const Color(0xff2a2a2a).withOpacity(0.5),
                  ),
                ),
                _mediaShowView(),
                Visibility(
                    visible: imageData.length >= 6 ? true : false,
                    child: SizedBox(
                      height: 120.px,
                    )),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            child: bottomView(),
          )
        ],
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

  Widget _mediaShowView() {
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

  Widget bottomView() {
    return Container(
      height: 41.5.px,
      color: const Color(0xFFE8F3FF),
      padding: EdgeInsets.symmetric(horizontal: 18.px),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.px),
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
                  final result = await Get.toNamed(Routes.atUser);
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
      ),
    );
  }

  openFilePicker() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage(limit: 9);
    if (files.length > 9 || files.length + imageData.length > 9) {
      ToastUtils.showToast('最多9张图片');
      return;
    }
    for (var file in files) {
      imageData.add(file.path);
    }
    setState(() {});
  }

  bool isCanOpenPicker() {
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

    String content = _controller.text;

    if (imageUrlList.isNotEmpty) {
      imageUrlList.clear();
    }

    if (content.isEmpty) {
      ToastUtils.showToast('评论内容不能为空');
      return;
    }
    EasyLoading.show(status: 'loading...');

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
            NetRequest().commentCreate(widget.relType, widget.relId, content, at: aitList, files: imageUrlList, (data) {
              EventBusUtil.of.fire(EventRefreshPage(widget.relType));
              EasyLoading.dismiss();
              ToastUtils.showToast('发布成功');
              Navigator.pop(context);
            });
            // NetRequest().threadCreate(
            //     title,
            //     content,
            //     currentBord!.id!,
            //     customLabelList,
            //     imageUrlList,
            //     aitList,
            //         (data) {
            //       //通知刷新论坛列表
            //       EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);
            //       EasyLoading.dismiss();
            //       Navigator.pop(context);
            //     }, (errMsg) {
            //   isClickPublish = false;
            // });
          }
        }, (errMsg) {
          //上传文件失败
          EasyLoading.dismiss();
          ToastUtils.showToast('上传文件失败，请重新上传');
          _uploadMediaFail();
        }, (int sent, int total) {});
      });
    } else {
      NetRequest().commentCreate(widget.relType, widget.relId, content, (data) {
        EventBusUtil.of.fire(EventRefreshPage(widget.relType));
        EasyLoading.dismiss();
        ToastUtils.showToast('发布成功');
        Navigator.pop(context);
      });
    }
  }

  ///上传文件失败
  _uploadMediaFail() {
    if (_isMounted) {
      setState(() {
        imageUrlList.clear();
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

      if (match.start == selectionIndex - match[0]!.length) {
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
