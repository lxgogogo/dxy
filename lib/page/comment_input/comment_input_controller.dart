part of 'comment_input_screen.dart';

class CommentInputController extends GetxController {
  final String relType;
  final int relId;

  CommentInputController(this.relType, this.relId);

  final textInput = DetectableTextEditingController(regExp: detectionRegExp());

  final aitUserBeanList = <UserProfile>[];

  bool _canSend = false;

  void submit() {
    String text = textInput.text;
    if (text.isNotEmpty) {
      NetRequest().commentCreate('comment', relId, text, at: _aitUserData(), (data) {
        EventBusUtil.of.fire(EventRefreshPage(relType));
        ToastUtils.showToast('发布成功');
        Get.back();
      });
    } else {
      ToastUtils.showToast('评论内容不能低于5个字符');
    }
  }

  void onChanged(String value) {
    _canSend = value.isNotEmpty;
    safeUpdate();
  }

  Future<void> toAtUser() async {
    final result = await Get.toNamed(Routes.atUser);
    if (result != null) {
      aitUserBeanList.add(result);
      var nickname = result.nickname;
      String originalContent = textInput.text;
      final index = textInput.selection.baseOffset;
      if (originalContent.isEmpty) {
        textInput.text = '@$nickname ';
      } else if (index >= originalContent.length - 1) {
        textInput.text = '$originalContent @$nickname ';
      } else {
        textInput.text =
            '${originalContent.substring(0, index)} @$nickname ${originalContent.substring(index - 1, originalContent.length - 1)}';
      }
    }
  }

  List<int> _aitUserData() {
    final aitList = <int>[];
    String content = textInput.text;
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
}
