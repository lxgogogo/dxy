part of 'feed_post_screen.dart';

class FeedPostController extends GetxController {
  late final List<BoardInfo> boardInfoList;

  final TextEditingController titleInput = TextEditingController();

  final SuperTooltipController tipController = SuperTooltipController();

  BoardInfo? get currentBord =>
      prefixIndex != -1 && prefixIndex < boardInfoList.length ? boardInfoList[prefixIndex] : null;
  int prefixIndex = -1;

  final QuillController quillController = QuillController.basic();
  final FocusNode focusNode = FocusNode();

  bool isClickPublish = false;

  List<TagModel> tagList = [];

  final int tagMaxLength = 5;

  @override
  void onInit() {
    boardInfoList = Get.arguments as List<BoardInfo>? ?? [];
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    focusNode.addListener(() {
      safeUpdate();
    });
  }

  void publishPosts() async {
    String title = titleInput.text;
    final QuillDeltaToHtmlConverter converter = QuillDeltaToHtmlConverter(
      List.castFrom(quillController.document.toDelta().toJson()),
      ConverterOptions.forEmail(),
    );
    final atList = [];
    converter.renderCustomWith = ((customOp, contextOp) {
      // if (customOp.insert.type == 'divider') {
      //   return '<hr/>';
      // }
      if (customOp.insert.type == 'at') {
        final Map<String, dynamic> dataMap = jsonDecode(customOp.insert.value);
        atList.add(dataMap['id']);
        return "<span style='color: #249cfc; position: relative; z-index: 1;'>@${dataMap['nickname']} </span>";
      }
      return '';
    });
    final richText = converter.convert().replaceAllMapped(RegExp(r'\$\$(.*?)\$\$'), (match) => '');

    final pureText = HtmlParseUtil.of.pureText(richText);

    final imageList = HtmlParseUtil.of.imageList(richText);

    if (currentBord == null || currentBord?.id == -1) {
      ToastUtils.showToast('请选择发帖板块');
      return;
    }

    if (title.isEmpty || title.length < 5) {
      ToastUtils.showToast('请输入5-31个字符标题');
      return;
    }

    if (richText.isEmpty || richText.length < 10) {
      ToastUtils.showToast('帖子内容长度不能小于10个字符');
      return;
    }
    if (isClickPublish) {
      return;
    }
    isClickPublish = true;

    final success = await NetRequest()
        .threadCreate(
      title,
      richText,
      pureText,
      currentBord!.id!,
      atList: atList,
      files: imageList,
      tagIds: tagList.map((e) => e.id).toList(),
    )
        .whenComplete(() {
      isClickPublish = false;
    });
    if (success) {
      EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);

      Get.back();
    }
  }

  Future<void> onImageInsertCallback(String image, QuillController controller) async {
    int count = 0;
    final operations = quillController.document.toDelta().toJson();
    for (final data in operations) {
      if (data.containsKey('insert')) {
        if (data['insert'] is Map) {
          if (data['insert'].containsKey('image')) {
            count++;
          }
        }
      }
    }
    if (count == 9) {
      ToastUtils.showToast('最多只可上传9张图片');
      return;
    }
    final fileLength = await File(image).length();
    if (fileLength > 10 * 1024 * 1024) {
      ToastUtils.showToast('上传图片不得超过10M');
      return;
    }
    final res = await NetRequest().uploadImage(image);
    if (res != null) {
      final uploadFile = UploadFile.fromJson(res);
      final imageUrl = uploadFile.url ?? '';
      if (imageUrl.isNotEmpty) {
        controller.insertImageBlock(imageSource: '$imageUrl\$\$$image\$\$');
      }
    }
  }

  Future<void> toAddTag() async {
    final tag = await Get.bottomSheet<TagModel?>(
      const TagListScreen(),
      isScrollControlled: true,
    );
    if (tag != null) {
      if (tagList.any((e) => e.id == tag.id)) {
        ToastUtils.showToast('不可重复插入同一话题');
        return;
      }
      tagList.add(tag);
      safeUpdate();
    }
  }

  void removeTag(int index) {
    tagList.removeAt(index);
    safeUpdate();
  }
}
