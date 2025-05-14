import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/toast_utils.dart';

class DeleteAccountController extends GetxController {

  bool isDisable = true;

  String get verifyType => Constants.verifyTypeEmail;

  String get verifyCodeType => Constants.verifyCodeTypeDeleteAccount;

  final TextEditingController controllerEmail = TextEditingController();
  final FocusNode focusEmail = FocusNode();

  final String deleteText = 'DELETE ACCOUNT';

  void checkValid() {
    final account = controllerEmail.text;
    isDisable = account.isEmpty || account != deleteText;
  }

  @override
  void onReady() {
    super.onReady();
    focusEmail.addListener(() {
      if (!focusEmail.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void onClose() {
    controllerEmail.dispose();
    focusEmail.dispose();
    super.onClose();
  }

  void reviseOnTap() async {
    if (isDisable) {
      ToastUtils.showToast('请输入$deleteText');
      return;
    }
    final res = await UserService.of.deleteAccount();
    if (res.isSuccess) {
      ToastUtils.showToast('注销成功');
      EventBusUtil.of.fire(EventResetMainTab());
      UserStore.of.clearUserStorage();
      Get.until((route) => route.settings.name == Routes.main);
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
