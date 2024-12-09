part of 'comment_publish_screen.dart';

class CommentPublishController extends GetxController {
  late String relType;
  late int relId;

  @override
  void onInit() {
    relType = Get.arguments['relType'] as String? ?? '';
    relId = Get.arguments['relId'] as int? ?? 0;
    super.onInit();
  }

  final _controller = DetectableTextEditingController(
    regExp: detectionRegExp(),
  );

  final imageData = []; //选择相册返回的本地地址集合
  final imageUrlList = <UploadFile>[]; //发布提交是的图片地址集合
  final aitUserBeanList = <UserProfile>[]; //@返回的所有用户集合，

  String aitUserContent = ''; //@用户的内容

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
    safeUpdate();
  }

  bool isCanOpenPicker() {
    if (imageData.length == 9) {
      return false;
    }
    return true;
  }

  Future<void> toAtUser() async {
    final result = await Get.toNamed(Routes.atUser);
    if (result != null) {
      aitUserBeanList.add(result);
      var nickname = result.nickname;
      String originalContent = _controller.text;
      final index = _controller.selection.baseOffset;
      if (originalContent.isEmpty) {
        _controller.text = '@$nickname ';
      } else if (index >= originalContent.length - 1) {
        _controller.text = '$originalContent @$nickname ';
      } else {
        _controller.text =
            '${originalContent.substring(0, index)} @$nickname ${originalContent.substring(index - 1, originalContent.length - 1)}';
      }
    }
  }

  List<int> _aitUserData() {
    final aitList = <int>[];
    String content = _controller.text;
    Iterable<Match> matches = atSignRegExp.allMatches(content);
    List<String> containsAitStrList = [];
    List<String> splitNameList = [];

    for (Match match in matches) {
      var matchStr = match.group(0);
      containsAitStrList.add(matchStr!);
    }
    if (containsAitStrList.isNotEmpty) {
      for (String aitStr in containsAitStrList) {
        content = content.replaceAll(aitStr, "");
        List<String> aitStrList = aitStr.split('@');
        splitNameList.add(aitStrList[1]);
      }
    }

    if (splitNameList.isNotEmpty) {
      for (String userName in splitNameList) {
        for (UserProfile userProfile in aitUserBeanList) {
          if (userName == userProfile.nickname) {
            aitList.add(userProfile.id!); //@用户的id集合
          }
        }
      }
    }
    return aitList;
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
            NetRequest().commentCreate(relType, relId, content, at: _aitUserData(), files: imageUrlList, (data) {
              EventBusUtil.of.fire(EventRefreshPage(relType));
              EasyLoading.dismiss();
              ToastUtils.showToast('发布成功');
              Get.back();
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
      NetRequest().commentCreate(relType, relId, content, (data) {
        EventBusUtil.of.fire(EventRefreshPage(relType));
        EasyLoading.dismiss();
        ToastUtils.showToast('发布成功');
        Get.back();
      });
    }
  }

  ///上传文件失败
  _uploadMediaFail() {
    imageUrlList.clear();
    safeUpdate();
  }

  void deleteMediaItem(String filePath) {
    imageData.remove(filePath);
    safeUpdate();
  }
}
