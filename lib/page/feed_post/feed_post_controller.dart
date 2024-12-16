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

  bool showKeyboard = false;

  bool showTextStyle = false;

  final textAttributes = [
    AttributeModel(
      '标题',
      Attribute.header,
      children: [
        AttributeModel('H1 标题', Attribute.h1),
        AttributeModel('H2 标题', Attribute.h2),
        AttributeModel('H3 标题', Attribute.h3),
        AttributeModel('H4 标题', Attribute.h4),
        AttributeModel('H5 标题', Attribute.h5),
      ],
    ),
    AttributeModel('加粗', Attribute.bold),
    AttributeModel('引用', Attribute.blockQuote),
    AttributeModel('有序列表', Attribute.ul),
    AttributeModel('无序列表', Attribute.ol),
    AttributeModel('分割线', Attribute.divider),
  ];
  bool showMore = false;

  final moreAttributes = [
    AttributeModel('添加链接', Attribute.link),
    AttributeModel('添加视频', Attribute.video),
    AttributeModel('提到', Attribute.at),
  ];

  bool isClickPublish = false;

  @override
  void onInit() {
    boardInfoList = Get.arguments as List<BoardInfo>? ?? [];
    super.onInit();
  }

  _openMore() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    showKeyboard = false;
    showTextStyle = false;
    showMore = true;
    safeUpdate();
  }

  _openTextStyle() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    showKeyboard = false;
    showTextStyle = true;
    textAttributes.first.isSelected = false;
    showMore = false;
    safeUpdate();
  }

  void publishPosts() async {
    String title = titleInput.text;
    final QuillDeltaToHtmlConverter converter = QuillDeltaToHtmlConverter(
      List.castFrom(quillController.document.toDelta().toJson()),
      ConverterOptions.forEmail(),
    );
    final atList = [];
    converter.renderCustomWith = ((customOp, contextOp) {
      if (customOp.insert.type == 'divider') {
        return '<hr>';
      }
      if (customOp.insert.type == 'at') {
        final Map<String, dynamic> dataMap = jsonDecode(customOp.insert.value);
        atList.add(dataMap['id']);
        return "<span style='color: #249cfc; position: relative; z-index: 1;'>@${dataMap['nickname']} </span>";
      }
      return '';
    });
    final content = converter.convert();

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
    if (isClickPublish) {
      return;
    }
    isClickPublish = true;

    final success = await NetRequest()
        .threadCreate(
      title,
      content,
      currentBord!.id!,
      atList: atList,
    )
        .whenComplete(() {
      isClickPublish = false;
    });
    if (success) {
      EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);

      Get.back();
    }
  }

  bool onTapDownEditor(TapDragDownDetails details, TextPosition Function(Offset offset) function) {
    if (!showKeyboard) {
      showKeyboard = true;
      showTextStyle = false;
      showMore = false;
      safeUpdate();
    }
    return false;
  }
}
