part of 'comment_publish_screen.dart';

class CommentPublishController extends GetxController {
  late String relType;
  late int relId;

  CommentPublishController(this.relType,this.relId);

  // @override
  // void onInit() {
  //   relType = Get.arguments['relType'] as String? ?? '';
  //   relId = Get.arguments['relId'] as int? ?? 0;
  //   super.onInit();
  // }

  final QuillController quillController = QuillController.basic();
  final FocusNode focusNode = FocusNode();

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

  void submit() {
    final QuillDeltaToHtmlConverter converter = QuillDeltaToHtmlConverter(
      List.castFrom(quillController.document.toDelta().toJson()),
      ConverterOptions.forEmail(),
    );
    final atList = [];
    converter.renderCustomWith = ((customOp, contextOp) {
      if (customOp.insert.type == 'at') {
        final Map<String, dynamic> dataMap = jsonDecode(customOp.insert.value);
        atList.add(dataMap['id']);
        return "<span style='color: #249cfc; position: relative; z-index: 1;'>@${dataMap['nickname']} </span>";
      }
      return '';
    });

    final content = converter.convert();

    if (imageUrlList.isNotEmpty) {
      imageUrlList.clear();
    }
   final isEmpty = HtmlParseUtil.of.isEmptyText(content);;
    if (isEmpty&&imageData.isEmpty) {
      ToastUtils.showToast('评论内容不能为空');
      return;
    }
    EasyLoading.show(status: 'loading...');

    //图片类型：
    if (imageData.isNotEmpty) {
      //有图
      imageData.forEach((element) async {
        NetRequest().uploadFile(element, (data) {
          UploadFile uploadFile = UploadFile.fromJson(data);
          imageUrlList.add(uploadFile);
          if (imageUrlList.isNotEmpty && imageUrlList.length == imageData.length) {
            NetRequest().commentCreate(relType, relId, content, at: atList, files: imageUrlList, (data) {
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
      NetRequest().commentCreate(relType, relId, content, at: atList, (data) {
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
