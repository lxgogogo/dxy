import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';

import '../../utils/toast_utils.dart';

part 'count_down_controller.dart';

class CountDownView extends StatelessWidget {
  final String type;
  final String email;

  const CountDownView({
    super.key,
    required this.type,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountDownController>(
      init: CountDownController(),
      builder: (controller) {
        if (controller.isCountingDown) {
          return Text(
            '${controller.countdown}s',
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
              ToastUtils.showToast('请输入正确格式邮箱');
              return;
            }
            controller.startCountdown(type, email);
          },
          child: Text(
            '发送验证码',
            style: TextStyle(
              fontSize: 14.sp,
              color: '#008EFF'.hexColor,
            ),
          ),
        );
      },
    );
  }
}
