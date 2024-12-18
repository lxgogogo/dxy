part of 'comment_input_screen.dart';

class CommentInputController extends GetxController {
  final String relType;
  final int relId;

  CommentInputController(this.relType, this.relId);

  final QuillController quillController = QuillController.basic();

  final aitUserBeanList = <UserProfile>[];

  bool canSend = false;

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
      ToastUtils.showToast('评论内容不能为空');
      return;
    }
    NetRequest().commentCreate('comment', relId, content, at: atList, (data) {
      EventBusUtil.of.fire(EventRefreshPage(relType));
      ToastUtils.showToast('发布成功');
      Get.back();
    });
  }
}
