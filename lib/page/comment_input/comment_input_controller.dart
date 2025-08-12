part of 'comment_input_screen.dart';

class CommentInputController extends GetxController {
  final String relType;
  final int relId;
  final SourceType sourceType;
  final int? sourceId;

  CommentInputController(
    this.relType,
    this.relId,
    this.sourceType,
    this.sourceId,
  );

  final QuillController quillController = QuillController.basic();

  final aitUserBeanList = <UserProfile>[];

  bool canSubmit = false;

  @override
  void onReady() {
    quillController.addListener(() {
      final QuillDeltaToHtmlConverter converter = QuillDeltaToHtmlConverter(
        List.castFrom(quillController.document.toDelta().toJson()),
        ConverterOptions.forEmail(),
      );
      final content = converter.convert();
      final isEmptyText = HtmlParseUtil.of.isEmptyText(content);
      canSubmit = !isEmptyText;
      safeUpdate();
    });
    super.onReady();
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
    if (content == '<p><br/></p>') {
      DialogUtil.showToast('评论内容不能为空');
      return;
    }
    NetRequest().commentCreate('comment', relId, content, at: atList, (data) {
      DialogUtil.showToast('发布成功');
      Get.back();
      EventBusUtil.of.fire(EventRefreshComments(relType));
      switch (sourceType) {
        case SourceType.video:
          TrackUtils.trackEvent(userLogType: '103007', params: sourceId);
          break;
        case SourceType.course:
          TrackUtils.trackEvent(userLogType: '105006', params: sourceId);
          break;
        case SourceType.book:
          TrackUtils.trackEvent(userLogType: '107007', params: sourceId);
          break;
        case SourceType.feed:
          TrackUtils.trackEvent(userLogType: '109006', params: sourceId);
          break;
        case SourceType.tool:
        // TODO: Handle this case.
      }
    });
  }
}
