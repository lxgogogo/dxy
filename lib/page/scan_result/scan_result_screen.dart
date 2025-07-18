import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../services/index.dart';
import '../../utils/dialog_util.dart';

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              controller.isSuccess || controller.isValid ? Assets.svg.scanSuccess : Assets.svg.scanFailed,
              width: 82.w,
              height: 82.w,
            ),
            SizedBox(height: 48.w),
            Text(
              controller.isSuccess
                  ? '登录成功'
                  : controller.isValid
                      ? '德学院登录确认'
                      : '当前二维码已过期',
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 196.w),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (controller.isSuccess || !controller.isValid) {
                    Get.back();
                    return;
                  }
                  controller.onConfirm();
                },
                child: Container(
                  height: 48.w,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF557BF6),
                        Color(0xFF84BCF9),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    controller.isSuccess ? '返回' : '确定',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
