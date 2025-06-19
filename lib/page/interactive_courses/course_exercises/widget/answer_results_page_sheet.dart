import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:lottie/lottie.dart';

class AnswerResultsPageSheet {
  static show(int pageType, Function sureOnTap,
      {int integral = 0, String pairsText = '', bool showPairsTips = false}) {
    Get.dialog(
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.65),
        AnswerResultsPageWidget(
          pageType: pageType,
          sureOnTap: sureOnTap,
          integral: integral,
          pairsText: pairsText,
          showPairsTips: showPairsTips,
        ));
  }
}

class AnswerResultsPageWidget extends StatefulWidget {
  // 0 - 失败 1 - 成功 2 - 连对5题
  final int pageType;
  final int integral;
  final String pairsText;
  final bool showPairsTips;
  final Function sureOnTap;
  const AnswerResultsPageWidget(
      {super.key,
      required this.pageType,
      required this.sureOnTap,
      this.integral = 0,
      this.pairsText = '',
      this.showPairsTips = false});

  @override
  State<StatefulWidget> createState() {
    return _AnswerResultsPageWidgetState();
  }
}

class _AnswerResultsPageWidgetState extends State<AnswerResultsPageWidget> {

  bool _showBtn = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _showBtn = true;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double top = 86.w;
    if (widget.pageType == 1) {
      return Center(
          child: SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Lottie.asset(
                      _evenPairsIcon(),
                      width: 1.2.sw,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                    ),
                  ),
                  if (_showBtn)...[
                    Positioned(
                        top: top + 330.w,
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
                              '${widget.integral}',
                              style:
                              TextStyle(fontSize: 14.sp, color: Colors.white),
                            ),
                          ],
                        )),
                    Positioned(
                        bottom: 20.w,
                        child: GestureDetector(
                          onTap: () {
                            widget.sureOnTap();
                          },
                          child: Container(
                            width: 1.sw - 32.w,
                            height: 50.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: ColorStyle.c557BF6,
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.w))),
                            child: Text(
                              '继续',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ))
                  ]
                ],
              )));
    } else if (widget.pageType == 2) {
      int companiesNumber = getCompaniesNumber();
      String json = 'assets/lottie/course_result_$companiesNumber.json';
      return Center(
          child: SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Lottie.asset(
                      json,
                      width: 1.2.sw,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                    ),
                  ),
                  if (widget.showPairsTips)
                    if (_showBtn)
                      Positioned(
                        top: top + 330.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '连击奖励：',
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.white),
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
                              '${widget.integral}',
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.white),
                            ),
                          ],
                        )),
                  if (_showBtn)
                    Positioned(
                      bottom: 20.w,
                      child: GestureDetector(
                        onTap: () {
                          widget.sureOnTap();
                        },
                        child: Container(
                          width: 1.sw - 32.w,
                          height: 50.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: ColorStyle.c557BF6,
                              borderRadius:
                              BorderRadius.all(Radius.circular(8.w))),
                          child: Text(
                            '继续',
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
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
                  child: Lottie.asset(
                    'assets/lottie/course_fail.json',
                    width: 1.2.sw,
                    fit: BoxFit.contain,
                    repeat: false,
                    animate: true,
                  ),
                ),
                if (_showBtn)...[
                  Positioned(
                      bottom: 20.w,
                      child: GestureDetector(
                        onTap: () {
                          widget.sureOnTap();
                        },
                        child: Container(
                          width: 1.sw - 32.w,
                          height: 50.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: ColorStyle.c557BF6,
                              borderRadius:
                              BorderRadius.all(Radius.circular(8.w))),
                          child: Text(
                            '继续',
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ))
                ]
              ],
            )));
  }

  int getCompaniesNumber() {
    if (widget.pairsText.contains('一') || widget.pairsText.contains('1')) {
      return 1;
    } else if (widget.pairsText.contains('二') || widget.pairsText.contains('2')) {
      return 2;
    } else if (widget.pairsText.contains('三') || widget.pairsText.contains('3')) {
      return 3;
    } else if (widget.pairsText.contains('四') || widget.pairsText.contains('4')) {
      return 4;
    } else if (widget.pairsText.contains('五') || widget.pairsText.contains('5')) {
      return 5;
    } else if (widget.pairsText.contains('六') || widget.pairsText.contains('6')) {
      return 6;
    } else if (widget.pairsText.contains('七') || widget.pairsText.contains('7')) {
      return 7;
    } else if (widget.pairsText.contains('八') || widget.pairsText.contains('8')) {
      return 8;
    } else if (widget.pairsText.contains('九') || widget.pairsText.contains('9')) {
      return 9;
    }
    return 10;
  }

  String _evenPairsIcon() {
    final random = Random();
    int randomNumber = random.nextInt(5) + 1;
    return 'assets/lottie/course_perfect_$randomNumber.json';
  }
}
