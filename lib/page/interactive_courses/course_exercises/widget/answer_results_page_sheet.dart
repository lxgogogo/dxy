import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/widget/button.dart';

class AnswerResultsPageSheet {
  static show(int pageType, Function sureOnTap, {int integral = 0}) {
    Get.dialog(
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
        AnswerResultsPageWidget(
            pageType: pageType, sureOnTap: sureOnTap, integral: integral));
  }
}

class AnswerResultsPageWidget extends StatelessWidget {
  // 0 - 失败 1 - 成功 2 - 连对5题
  final int pageType;
  final int integral;
  final Function sureOnTap;
  const AnswerResultsPageWidget(
      {super.key,
      required this.pageType,
      required this.sureOnTap,
      this.integral = 0});

  @override
  Widget build(BuildContext context) {
    double top = 86.w;
    if (pageType == 1) {
      return Center(
          child: SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: top,
                    child: Image.asset('assets/courses/icon_results_title1.png',
                        width: 180.w),
                  ),
                  Positioned(
                    top: top,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/courses/icon_results_bg_sang.png',
                            width: 340.w),
                        Image.asset('assets/courses/icon_results_bg_jiang2.png',
                            width: 200.w),
                      ],
                    ),
                  ),
                  Positioned(
                    top: top + 250.w,
                    child: Image.asset(
                        'assets/courses/icon_results_liandui1.png',
                        width: 1.sw),
                  ),
                  Positioned(
                      top: top + 380.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '连击奖励：',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                          SizedBox(width: 10.w),
                          Image.asset(
                            'assets/courses/icon_results_arrow.png',
                            width: 16.w,
                          ),
                          SizedBox(width: 20.w),
                          Image.asset(
                            'assets/courses/icon_course_excus.png',
                            width: 16.w,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$integral',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                        ],
                      )),
                  Positioned(
                      top: top + 450.w,
                      child: GestureDetector(
                        onTap: () {
                          Get.close(0);
                        },
                        child: Image.asset(
                            'assets/courses/icon_results_close.png',
                            width: 32.w),
                      )),
                  Positioned(
                    top: top + 520.w,
                    child: CustomButton(
                      width: 1.sw - 32.w,
                      onPressed: () {
                        sureOnTap();
                      },
                      disable: false,
                      showOpacityAnimation: true,
                      textColor: Colors.white,
                      height: 50.w,
                      radius: 8.w,
                      title: '继续',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              )));
    } else if (pageType == 2) {
      return Center(
          child: SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: top,
                    child: Image.asset('assets/courses/icon_results_title.png',
                        width: 180.w),
                  ),
                  Positioned(
                    top: top,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/courses/icon_results_bg_sang.png',
                            width: 340.w),
                        Image.asset('assets/courses/icon_results_bg_jiang.png',
                            width: 200.w),
                      ],
                    ),
                  ),
                  Positioned(
                    top: top + 290.w,
                    child: Image.asset(
                        'assets/courses/icon_results_liandui.png',
                        width: 1.sw),
                  ),
                  Positioned(
                      top: top + 490.w,
                      child: GestureDetector(
                        onTap: () {
                          sureOnTap();
                        },
                        child: Image.asset(
                            'assets/courses/icon_results_close.png',
                            width: 32.w),
                      )),
                ],
              )));
    }
    return Center(
        child: SizedBox(
            width: 1.sw,
            height: 1.sh,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: top,
                  child: Image.asset('assets/courses/icon_results_title3.png',
                      width: 180.w),
                ),
                Positioned(
                  top: top,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/courses/icon_results_bg_sang.png',
                          width: 340.w),
                      Image.asset('assets/courses/icon_results_bg_jiang3.png',
                          width: 200.w),
                    ],
                  ),
                ),
                Positioned(
                    top: top + 300.w,
                    child: Text(
                      '再刷一遍\n失手的题目吧!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                Positioned(
                    top: top + 420.w,
                    child: GestureDetector(
                      onTap: () {
                        Get.close(0);
                      },
                      child: Image.asset(
                          'assets/courses/icon_results_close.png',
                          width: 32.w),
                    )),
                Positioned(
                  top: top + 510.w,
                  child: CustomButton(
                    width: 1.sw - 32.w,
                    onPressed: () {
                      sureOnTap();
                    },
                    disable: false,
                    showOpacityAnimation: true,
                    textColor: Colors.white,
                    height: 50.w,
                    radius: 8.w,
                    title: '继续',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            )));
  }
}
