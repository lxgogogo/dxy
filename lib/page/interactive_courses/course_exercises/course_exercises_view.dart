import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    return Scaffold(body: Obx(() {
      double width = 1.sw - 126.w;
      double progress = 0;
      if (controller.totalPage > 0 && controller.practiseList.isNotEmpty) {
        progress =
            width * ((controller.currentPage.value+ controller.completed) / controller.totalPage);
      }
      return Container(
        margin: EdgeInsets.only(top: 56.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.isLoading.value || controller.totalPage == 0)
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
                  SizedBox(width: 60.w)
                ],
              )
            else
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
                          width: width,
                          height: 8.w,
                          decoration: BoxDecoration(
                              color: AppTheme.color_333333.withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.w))),
                        ),
                        Container(
                          width: progress,
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
                      width: 50.w,
                      child: Row(
                        children: [
                          Image.asset(
                            Assets.courses.iconCourseExcus.path,
                            width: 16.w,
                            height: 16.w,
                          ),
                          SizedBox(width: 5.w),
                          AutoSizeText(
                            '${controller.integral}',
                            minFontSize: 7,
                            style: TextStyle(
                                fontSize: 14.sp, color: AppTheme.color_666666),
                          )
                        ],
                      ))
                ],
              ),
            if (controller.isLoading.value)
              const Expanded(
                  child: Center(
                child: CupertinoActivityIndicator(color: Colors.grey),
              ))
            else if (controller.practiseList.isEmpty)
              const Expanded(child: Center(child: NoDataView()))
            else
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...controller.practiseList.map((model) {
                      return _buildPageWidget(model);
                    })
                  ],
                ),
              ),
          ],
        ),
      );
    }));
  }

  Widget _buildPageWidget(model) {
    return Column(
      children: [
        SizedBox(height: 20.w),
        Expanded(
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.w),
              HtmlWidget(
                model.content ?? '',
                customStylesBuilder: htmlCustomStyles,
                factoryBuilder: () => HtmlFactoryBuilder(
                  context,
                  content: model.content ?? '',
                ),
                customWidgetBuilder: (element) {
                  if (element.localName == 'table') {
                    return const SizedBox();
                  }
                  return null;
                },
                onTapUrl: (String url) async {
                  return launchUrlString(url,
                      mode: LaunchMode.externalApplication);
                },
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
        GestureDetector(
          onTap: controller.onPressed,
          child: Container(
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: controller.selectAnswerModel == null
                    ? ColorStyle.c333333.withOpacity(0.1)
                    : ColorStyle.c557BF6,
                borderRadius: BorderRadius.all(Radius.circular(8.w))),
            child: Text(
              '提交',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: controller.selectAnswerModel == null
                      ? AppTheme.color_999999
                      : Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 70.w)
      ],
    );
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
