import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/services/index.dart';

import '../../utils/toast_utils.dart';

part 'count_down_controller.dart';

class CountDownView extends GetView<CountDownController> {
  final String verifyType;
  final String verifyCodeType;
  final String codeTypeDesc;
  final String account;

  const CountDownView({
    super.key,
    required this.verifyType,
    required this.verifyCodeType,
    required this.codeTypeDesc,
    required this.account,
  });

  @override
  String? get tag => '$verifyType$verifyCodeType';

  @override
  CountDownController get controller => Get.put(
        CountDownController(),
        tag: tag,
        permanent: true,
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.countdown.value > 0) {
        return Text(
          '${controller.countdown.value}s',
          style: TextStyle(
            fontSize: 14.sp,
            color: '#008EFF'.hexColor,
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          if (account.isEmpty) {
            ToastUtils.showToast('$codeTypeDesc不能为空');
            return;
          }
          // if (!GetUtils.isEmail(account)) {
          //   ToastUtils.showToast('请输入正确$codeTypeDesc');
          //   return;
          // }
          controller.startCountdown(verifyType, verifyCodeType, account);
        },
        child: Text(
          '获取验证码',
          style: TextStyle(
            fontSize: 10.sp,
            color: '#557BF6'.hexColor,
          ),
        ),
      );
    });
  }
}
