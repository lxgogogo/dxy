import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/button.dart';

import 'course_exercises_controller.dart';

class CourseExercisesPage extends StatefulWidget {
  const CourseExercisesPage({Key? key}) : super(key: key);

  @override
  State<CourseExercisesPage> createState() => _CourseExercisesPageState();
}

class _CourseExercisesPageState extends State<CourseExercisesPage> {
  final CourseExercisesController controller =
      Get.put(CourseExercisesController());

  @override
  void dispose() {
    Get.delete<CourseExercisesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => Container(
              margin: EdgeInsets.only(top: 56.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset(
                          Assets.images.labelClose.path,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 8.w,
                              decoration: BoxDecoration(
                                  color:
                                      AppTheme.color_333333.withOpacity(0.05),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.w))),
                            ),
                            Container(
                              width: 100.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                  color: AppTheme.color_557BF6,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.w))),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                          width: 50,
                          child: Row(
                            children: [
                              Image.asset(
                                Assets.courses.iconCourseExcus.path,
                                width: 16.w,
                                height: 16.w,
                              ),
                              SizedBox(width: 5.w),
                              AutoSizeText(
                                '88',
                                minFontSize: 7,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.color_666666),
                              )
                            ],
                          ))
                    ],
                  ),
                  SizedBox(height: 20.w),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '如下图，谁获胜呢？如下图，谁获胜呢？如下图，谁获胜呢？如下图，谁获胜呢？如下图，谁获胜呢？如下图，谁获胜呢？如下图，谁获胜...',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.color_333333),
                        ),
                        SizedBox(height: 10.w),
                        Image.asset(
                          Assets.courses.iconCourseExcusBg.path,
                          width: 1.sw,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 50.w),
                        Wrap(
                          runSpacing: 10.w,
                          children: [
                            ...controller.dataList.map((e) {
                              return _buildButtonWidget(e);
                            })
                          ],
                        )
                      ],
                    )),
                  ),
                  CustomButton(
                    onPressed: controller.onPressed,
                    disable: false,
                    showOpacityAnimation: true,
                    textColor: Colors.white,
                    height: 50.w,
                    radius: 8.w,
                    title: '提交',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 70.w)
                ],
              ),
            )));
  }

  Widget _buildButtonWidget(CourseExerciseAnswerModel model) {
    String title = model.title ?? '';
    bool select = model.select ?? false;
    bool isCorrect = model.isCorrect ?? false;
    Color borderColor = Colors.white;
    Color bgColor = Colors.white;
    Color titleColor = AppTheme.color_333333;
    Color shadowColor = '#0050FF'.hexColor.withOpacity(0.1);
    if (select && !controller.submit.value) {
      borderColor = AppTheme.color_557BF6;
      bgColor = AppTheme.color_557BF6.withOpacity(0.1);
      titleColor = AppTheme.color_557BF6;
    } else if (select && controller.submit.value && isCorrect) {
      borderColor = AppTheme.color_39B423;
      bgColor = AppTheme.color_39B423.withOpacity(0.1);
      titleColor = AppTheme.color_39B423;
      shadowColor = '#39B423'.hexColor.withOpacity(0.1);
    } else if (select && controller.submit.value && !isCorrect) {
      borderColor = ColorStyle.cFF3333;
      bgColor = ColorStyle.cFF3333.withOpacity(0.1);
      titleColor = ColorStyle.cFF3333;
      shadowColor = '#FF3333'.hexColor.withOpacity(0.1);
    }
    return GestureDetector(
        onTap: () {
          controller.selectOnTap(model);
        },
        child: Container(
          height: 46.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.all(Radius.circular(8.w)),
              boxShadow: [
                BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 4.32),
                    blurRadius: 8.63,
                    spreadRadius: 0)
              ],
              border: Border.all(width: 1.w, color: borderColor)),
          child: Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: titleColor),
          ),
        ));
  }
}
