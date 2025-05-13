import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'revise_phone_controller.dart';

class RevisePhonePage extends StatefulWidget {
  const RevisePhonePage({Key? key}) : super(key: key);

  @override
  State<RevisePhonePage> createState() => _RevisePhonePageState();
}

class _RevisePhonePageState extends State<RevisePhonePage> {
  final RevisePhoneController controller = Get.put(RevisePhoneController());

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<RevisePhoneController>();
    super.dispose();
  }
}