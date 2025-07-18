import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/page/scan/widgets/scan_area_rector.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../gen/assets.gen.dart';
import '../../services/index.dart';
import '../../utils/debounce_throttle_util.dart';
import '../../utils/dialog_util.dart';
import 'widgets/scan_area_clipper.dart';

part 'scan_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanController>(
      init: ScanController(),
      builder: (controller) => Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: controller.controller,
              onDetect: controller.onDetect,
            ),
            ClipPath(
              clipper: ScanAreaClipper(
                height: 238,
                width: 238,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(.5),
                ),
              ),
            ),
            const ScanAreaRector(
              height: 238,
              width: 238,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 20.w,
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.asset(
                          Assets.svg.arrowBack,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '扫码登录德学院',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 64,
              child: GestureDetector(
                onTap: controller.pickImage,
                behavior: HitTestBehavior.translucent,
                child: Column(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        Assets.svg.inputImage,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      '相册',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
