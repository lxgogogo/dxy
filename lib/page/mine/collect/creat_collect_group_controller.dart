import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';

class CreatCollectGroupController extends GetxController {

  final TextEditingController textController = TextEditingController();

  RxBool enable = false.obs;
  bool isCreate = true;

  @override
  void onInit() {
    super.onInit();
    isCreate = Get.arguments['create'] ?? false;
    textController.text = Get.arguments['title'] ?? '';
    enable.value = textController.text.isEmpty ? false : true;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void signUpOnTap() {
    if (isCreate) {
      Get.toNamed(Routes.finishCreateCollect);
    } else {
      Get.back();
    }
  }
}
