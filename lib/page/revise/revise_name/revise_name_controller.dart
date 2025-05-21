import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';

class ReviseNameController extends GetxController {

  final ValueNotifier<bool> isDisable = ValueNotifier(true);
  final ValueNotifier<int> textLength = ValueNotifier(0);
  final TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    String nickName = UserStore.of.user?.nickname ?? '';
    textEditingController.text = nickName;
    textEditingController.addListener(() {
      textLength.value = textEditingController.text.length;
      isDisable.value = textEditingController.text.isEmpty ||
          textEditingController.text == nickName;
    });
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  void reviseOnTap(context) async {
    String nickname = textEditingController.text;
    if (nickname.characters.length > 10) {
      ToastUtils.showToast('昵称不能超过10个字');
      return;
    }
    NetRequest().userUpdate(nickname, (data) {
      ToastUtils.showToast('修改成功');
      UserStore.of.getUserInfo();
      Navigator.pop(context);
    }, showLoading: true);
  }
}
