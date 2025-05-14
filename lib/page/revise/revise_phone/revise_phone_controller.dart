import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/toast_utils.dart';

class RevisePhoneController extends GetxController {
  bool isDisable = true;

  String get verifyType => Constants.verifyTypePhone;

  String get verifyCodeType => Constants.verifyCodeTypeChangePhone;

  final TextEditingController controllerMobile = TextEditingController();
  RxBool isShowMobileTips = false.obs;
  final FocusNode focusMobile = FocusNode();
  final TextEditingController controllerCode = TextEditingController();
  RxBool isShowCodeTips = false.obs;
  final FocusNode focusCode = FocusNode();

  @override
  void onReady() {
    super.onReady();
    controllerMobile.text = UserStore.of.user?.phone ?? '';
    focusMobile.addListener(() {
      if (!focusMobile.hasFocus) {
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
    controllerMobile.dispose();
    controllerCode.dispose();
    focusMobile.dispose();
    focusCode.dispose();
    super.onClose();
  }

  void checkValid() {
    final mobile = controllerMobile.text;
    isShowMobileTips.value =
        !(Constants.phoneRegExp.hasMatch(mobile) && mobile.isNotEmpty);
    final code = controllerCode.text;
    isShowCodeTips.value =
        !(Constants.codeRegExp.hasMatch(code) && code.isNotEmpty);
    isDisable = mobile.isEmpty ||
        isShowMobileTips.value ||
        code.isEmpty ||
        isShowCodeTips.value;
  }

  void reviseOnTap() async {
    if (isDisable) return;
    String phone = controllerMobile.text;
    String code = controllerCode.text;
    final res = await UserService.of.updatePhone(
      phone: phone,
      code: code,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('修改成功');
      UserStore.of.getUserInfo();
      Get.back();
      Get.delete<CountDownController>(tag: '$verifyType$verifyCodeType', force: true);
    } else {
      ToastUtils.showToast(res.msg);
    }
  }

}
