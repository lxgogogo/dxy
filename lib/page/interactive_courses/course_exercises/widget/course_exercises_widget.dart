
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/model/course_model.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CourseExercisesWidget extends StatefulWidget {
  final CourseModel item;
  const CourseExercisesWidget({super.key, required this.item});

  @override
  State<StatefulWidget> createState() {
    return _CourseExercisesWidgetState();
  }
}

class _CourseExercisesWidgetState extends State<CourseExercisesWidget> {

  final PageController _pageController = PageController();
  List<CourseExerciseModel> _practiseList = [];
  List<CourseExerciseAnswerModel> _dataList = [];
  CourseExerciseAnswerModel? _selectAnswerModel;
  bool _submit = false;
  int _currentPage = 0;

  // TODO: Private Method

  void _onPressed() {}

  void _selectOnTap(model) {}

  // TODO: Build Widget

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w).copyWith(right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: '#58A5FF'.hexColor.withOpacity(0.1),
            blurRadius: 8.63.r,
            offset: Offset(0, 4.32.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.iconPractice,
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '练习',
                style: TextStyle(
                  color: '#000000'.hexColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.w),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ..._practiseList.map((model) {
                return _buildPageWidget(model);
              })
            ],
          ),
          SizedBox(height: 12.w),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '进度：',
                        children: [
                          TextSpan(
                            text: '${widget.item.completed ?? 0}',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '/${widget.item.total ?? 0}',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: '#666666'.hexColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.svg.iconCourseIntegral,
                          width: 16.w,
                          height: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.item.integral ?? 0}',
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: double.infinity,
                    height: 4.w,
                    margin: EdgeInsets.symmetric(vertical: 8.w),
                    decoration: BoxDecoration(
                      color: '#333333'.hexColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: widget.item.progress * constraints.maxWidth,
                            color: '#557BF6'.hexColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Wrap(
                    spacing: 5.w,
                    children: List.generate(
                      widget.item.total ?? 0,
                          (index) {
                        final isCompleted = index < (widget.item.completed ?? 0);
                        return Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? '#557BF6'.hexColor.withOpacity(0.1)
                                : '#333333'.hexColor.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isCompleted
                                  ? '#557BF6'.hexColor
                                  : '#333333'.hexColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
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
                      ..._dataList.map((e) {
                        return _buildButtonWidget(e);
                      })
                    ],
                  ),
                  SizedBox(height: 10.w),
                ],
              )),
        ),
        SizedBox(height: 10.w),
        GestureDetector(
          onTap: _onPressed,
          child: Container(
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _selectAnswerModel == null
                    ? ColorStyle.c333333.withOpacity(0.1)
                    : ColorStyle.c557BF6,
                borderRadius: BorderRadius.all(Radius.circular(8.w))),
            child: Text(
              '提交',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: _selectAnswerModel == null
                      ? AppTheme.color_999999
                      : Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 60.w)
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
    if (select && !_submit) {
      borderColor = AppTheme.color_557BF6;
      bgColor = AppTheme.color_557BF6.withOpacity(0.1);
      titleColor = AppTheme.color_557BF6;
    } else if (select && _submit && isCorrect) {
      borderColor = AppTheme.color_39B423;
      bgColor = AppTheme.color_39B423.withOpacity(0.1);
      titleColor = AppTheme.color_39B423;
      shadowColor = '#39B423'.hexColor.withOpacity(0.1);
    } else if (select && _submit && !isCorrect) {
      borderColor = ColorStyle.cFF3333;
      bgColor = ColorStyle.cFF3333.withOpacity(0.1);
      titleColor = ColorStyle.cFF3333;
      shadowColor = '#FF3333'.hexColor.withOpacity(0.1);
    }
    return GestureDetector(
        onTap: () {
          _selectOnTap(model);
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