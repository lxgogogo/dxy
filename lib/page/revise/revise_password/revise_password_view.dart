import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'revise_password_controller.dart';

class RevisePasswordPage extends StatefulWidget {
  const RevisePasswordPage({Key? key}) : super(key: key);

  @override
  State<RevisePasswordPage> createState() => _RevisePasswordPageState();
}

class _RevisePasswordPageState extends State<RevisePasswordPage> {
  final RevisePasswordController controller = Get.put(RevisePasswordController());

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<RevisePasswordController>();
    super.dispose();
  }
}