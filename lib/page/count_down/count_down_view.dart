import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';

import '../../utils/toast_utils.dart';

part 'count_down_controller.dart';

class CountDownView extends GetView<CountDownController> {
  final String type;
  final String email;

  const CountDownView({
    super.key,
    required this.type,
    required this.email,
  });

  @override
  String? get tag => type;

  @override
  CountDownController get controller => Get.put(
    CountDownController(),
    tag: type,
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
          if (email.isEmpty) {
            ToastUtils.showToast('邮箱不能为空');
            return;
          }
          if (!GetUtils.isEmail(email)) {
            ToastUtils.showToast('请输入正确邮箱地址');
            return;
          }
          controller.startCountdown(type, email);
        },
        child: Text(
          '获取验证码',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: '#557BF6'.hexColor,
          ),
        ),
      );
    });
  }
}
