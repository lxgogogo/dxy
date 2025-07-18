import 'package:flutter/material.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';

import '../../../services/collect_service.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/dialog_util.dart';

class CreatCollectGroupController extends GetxController {

  final TextEditingController textController = TextEditingController();

  RxBool enable = false.obs;
  RxBool isCreate = true.obs;
  int id = 0;

  @override
  void onInit() {
    super.onInit();
    isCreate.value = Get.arguments['create'] ?? false;
    textController.text = Get.arguments['title'] ?? '';
    if (Get.arguments['id'] != null) {
      id = Get.arguments['id'] ?? 0;
    }
    enable.value = textController.text.isEmpty ? false : true;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void signUpOnTap() async {
    if (isCreate.value) {
      Get.toNamed(Routes.finishCreateCollect, arguments: {
        'name': textController.text,
        'create': true
      });
    } else {
      DialogUtil.showLoading();
      final res = await CollectService.saveCategoryCollect({
        'name': textController.text,
        'id': id
      });
      DialogUtil.dismiss();
      if (res.isSuccess) {
        EventBusUtil.of.fire(EventRefreshName(textController.text));
        DialogUtil.showToast('修改成功');
        Get.back();
      } else {
        DialogUtil.showToast(res.msg);
      }
    }
  }
}
