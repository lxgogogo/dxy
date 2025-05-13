import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/toast_utils.dart';

class ReviseAccountController extends GetxController {
  final TextEditingController controllerAccount = TextEditingController();
  final FocusNode focusEmail = FocusNode();

  RxBool isShowAccountTips = false.obs;

  @override
  void onReady() {
    super.onReady();
    controllerAccount.text = UserStore.of.user?.username ?? '';
    focusEmail.addListener(() {
      if (!focusEmail.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void onClose() {
    controllerAccount.dispose();
    super.onClose();
  }

  void checkValid() {
    final account = controllerAccount.text;
    isShowAccountTips.value =
    !(Constants.accountRegExp.hasMatch(account) && account.isNotEmpty);
  }

  void reviseOnTap() async {
    if (isShowAccountTips.value) {
      return;
    }
    String username = controllerAccount.text;
    // String password = _controllerOriginalPw.text;
    final res = await UserService.of.updateUsername(
      username: username,
      // password: password,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('绑定成功');
      UserStore.of.getUserInfo();
      Get.back();
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
