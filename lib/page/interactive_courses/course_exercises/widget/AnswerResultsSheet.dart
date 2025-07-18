import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';

class AnswerResultsSheet {
  static show(
      bool isCorrect, String answerStr, String tips, Function sureOnTap) {
    Get.bottomSheet(
        isDismissible: false,
        barrierColor: Colors.transparent,
        AnswerResultsWidget(
            isCorrect: isCorrect,
            answerStr: answerStr,
            tips: tips,
            sureOnTap: sureOnTap));
  }
}

class AnswerResultsWidget extends StatelessWidget {
  final bool isCorrect;
  final String answerStr;
  final String tips;
  final Function sureOnTap;
  const AnswerResultsWidget(
      {super.key,
      this.isCorrect = true,
      this.answerStr = '',
      this.tips = '',
      required this.sureOnTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: isCorrect ? 159.w : 195.w,
        color: isCorrect ? AppTheme.color_D0FFC8 : AppTheme.color_FFDCDE,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  isCorrect
                      ? Assets.courses.iconCoursesTrue.path
                      : Assets.courses.iconCoursesWrong.path,
                  width: 24.w,
                  height: 24.w,
                ),
                SizedBox(width: 5.w),
                Text(
                  tips,
                  style: TextStyle(
                      fontSize: 20.sp,
                      color: isCorrect
                          ? AppTheme.color_39B423
                          : ColorStyle.cFF3333,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (!isCorrect) ...[
              SizedBox(height: 10.w),
              Text(
                '正确答案：$answerStr',
                style: TextStyle(
                    fontSize: 16.sp,
                    color:
                        isCorrect ? AppTheme.color_39B423 : ColorStyle.cFF3333,
                    fontWeight: FontWeight.w600),
              )
            ],
            SizedBox(height: 20.w),
            GestureDetector(
              onTap: () {
                sureOnTap(isCorrect);
              },
              child: Container(
                height: 50.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.w)),
                    color:
                        isCorrect ? AppTheme.color_39B423 : ColorStyle.cFF3333),
                child: Text(
                  isCorrect ? '继续' : '重试',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            )
          ],
        ));
  }
}
