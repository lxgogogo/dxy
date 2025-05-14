import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/toast_utils.dart';

class ReviseEmailController extends GetxController {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerCode = TextEditingController();
  final FocusNode focusEmail = FocusNode();
  final FocusNode focusCode = FocusNode();

  String get verifyType => Constants.verifyTypeEmail;

  String get verifyCodeType => Constants.verifyCodeTypeChangeEmail;

  RegExp codeRegExp = RegExp(r'^\d{6}$');

  RxBool isShowAccountTips = false.obs;
  RxBool isShowCodeTips = false.obs;
  bool isDisable = false;

  @override
  void onReady() {
    super.onReady();
    controllerEmail.text = UserStore.of.user?.account ?? '';
    focusEmail.addListener(() {
      if (!focusEmail.hasFocus) {
        checkValid();
      }
    });
    focusCode.addListener(() {
      if (!focusCode.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void onClose() {
    controllerEmail.dispose();
    controllerCode.dispose();
    focusEmail.dispose();
    focusCode.dispose();
    super.onClose();
  }

  void checkValid() {
    final account = controllerEmail.text;
    isShowAccountTips.value = !(GetUtils.isEmail(account) && account.isNotEmpty);
    final code = controllerCode.text;
    isShowCodeTips.value = !(codeRegExp.hasMatch(code) && code.isNotEmpty);
    isDisable = account.isEmpty ||
        isShowAccountTips.value ||
        code.isEmpty ||
        isShowCodeTips.value;
    print('isDisable:$isDisable');
    print('isShowAccountTips:${isShowAccountTips.value}');
    print('isShowCodeTips:${isShowCodeTips.value}');
  }

  void reviseOnTap() async {
    if (isDisable) return;
    String email = controllerEmail.text;
    String code = controllerCode.text;
    final res = await UserService.of.updateEmail(
      email: email,
      code: code,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('绑定成功');
      UserStore.of.getUserInfo();
      Get.back();
      Get.delete<CountDownController>(
          tag: '$verifyType$verifyCodeType', force: true);
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
