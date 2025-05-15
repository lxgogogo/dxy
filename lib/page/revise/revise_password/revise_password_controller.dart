import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';

class RevisePasswordController extends GetxController {
  bool isDisable = true;

  final TextEditingController controllerOriginalPw = TextEditingController();

  RxBool isShowOriginalPwTips = false.obs;
  final FocusNode focusOriginalPw = FocusNode();
  RxBool originalPwdObscureText = true.obs;

  final TextEditingController controllerPw = TextEditingController();
  RxBool isShowPwTips = false.obs;
  final FocusNode focusPw = FocusNode();
  RxBool newPwdObscureText = true.obs;

  final TextEditingController controllerAgainPw = TextEditingController();
  RxBool isShowAgainTips = false.obs;
  final FocusNode focusAgainPw = FocusNode();
  RxBool confirmPwdObscureText = true.obs;
  RxBool isContainsInvalidChars = false.obs;

  @override
  void onReady() {
    super.onReady();
    focusPw.addListener(() {
      if (!focusPw.hasFocus) {
        checkValid();
      }
    });
    focusAgainPw.addListener(() {
      if (!focusAgainPw.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void checkValid() {
    final originalPassword = controllerOriginalPw.text;
    isShowOriginalPwTips.value =
        !(Constants.passwordRegExp.hasMatch(originalPassword) &&
            originalPassword.isNotEmpty);
    final password = controllerPw.text;
    isContainsInvalidChars.value =
        !Constants.containsInvalidChars.hasMatch(password);
    bool isValidPassword = Constants.passwordRegExp.hasMatch(password);

    if (password.isNotEmpty) {
      if (isContainsInvalidChars.value) {
        isShowPwTips.value = true; // 包含非法字符
      } else if (!isValidPassword) {
        isShowPwTips.value = true; // 不满足复杂度要求
      } else {
        isShowPwTips.value = false; // 所有条件均满足
      }
    } else {
      isShowPwTips.value = false; // 密码为空时不显示提示
    }
    final againPw = controllerAgainPw.text;
    isShowAgainTips.value = password != againPw && againPw.isNotEmpty;

    isDisable = originalPassword.isEmpty ||
        // isShowOriginalPwTips ||
        password.isEmpty ||
        isShowPwTips.value ||
        againPw.isEmpty ||
        isShowAgainTips.value;
  }

  void reviseOnTap(context) async {
    if (isDisable) {
      return;
    }
    NetRequest().updatePassword(controllerOriginalPw.text, controllerPw.text, (data) {
      ToastUtils.showToast('修改密码成功');
      Navigator.of(context).pop();
    });
  }
}
