import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/utils/track_utils.dart';

import '../../constants.dart';
import '../../utils/toast_utils.dart';

part 'count_down_controller.dart';

class CountDownView extends GetView<CountDownController> {
  final String verifyType;
  final String verifyCodeType;
  final String account;

  const CountDownView({
    super.key,
    required this.verifyType,
    required this.verifyCodeType,
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
          String desc = '';
          bool valid = false;
          if (verifyType == Constants.verifyTypeEmail) {
            desc = '邮箱';
            valid = GetUtils.isEmail(account);
          } else if (verifyType == Constants.verifyTypePhone) {
            desc = '手机号';
            valid = Constants.accountRegExp.hasMatch(account);
          }
          if (!valid) {
            ToastUtils.showToast('请输入正确的$desc');
            return;
          }
          controller.startCountdown(account, verifyType, verifyCodeType);
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
