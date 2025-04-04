import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/widget/common_app_bar.dart';

part 'scan_result_controller.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanResultController>(
      init: ScanResultController(),
      builder: (controller) => Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '扫码登录德学院'),
        body: Column(),
      ),
    );
  }
}
