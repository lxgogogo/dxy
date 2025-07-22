
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/model/course_model.dart';
import 'package:holdem/page/feed_detail/widgets/html_factory_builder.dart';
import 'package:holdem/page/feed_detail/widgets/html_style_builder.dart';
import 'package:holdem/page/interactive_courses/course_exercises/widget/AnswerResultsSheet.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../interactive_courses/course_exercises/widget/answer_results_page_sheet.dart';

class CourseExercisesWidget extends StatefulWidget {
  final CourseModel item;
  const CourseExercisesWidget({super.key, required this.item});

  @override
  State<StatefulWidget> createState() {
    return _CourseExercisesWidgetState();
  }
}

class _CourseExercisesWidgetState extends State<CourseExercisesWidget> {

  List<CourseExerciseModel> _practiseList = [];
  List<CourseExerciseAnswerModel> _dataList = [];
  CourseExerciseAnswerModel? _selectAnswerModel;
  bool _submit = false;
  int _currentPage = 0;
  int _integral = 0;
  int _completed = 0;
  int _totalPage = 0;
  bool _canEdit = true;

  // TODO: Private Method

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initData() {
    _completed = widget.item.completed ?? 0;
    _canEdit = _completed == widget.item.total ? false : true;
    final data = widget.item.practiseDto ?? {};
    _integral = data['integral'] ?? 0;
    _completed = data['completed'] ?? 0;
    _totalPage = data['total'] ?? 0;
    if (_completed <= 0) {
      _currentPage = 0;
    } else {
      _currentPage = _completed - 1;
    }
    final practiseData = data['practiseList'] ?? [];
    print('练习题数量:${practiseData.length}');
    print('_currentPage:$_currentPage');
    List<CourseExerciseModel> saveData = [];
    for (final json in practiseData) {
      CourseExerciseModel model = CourseExerciseModel.fromJson(json);
      saveData.add(model);
    }
    _practiseList = saveData;
    if (_practiseList.isNotEmpty) {
      final practiseModel = _practiseList[_currentPage];
      _dataList = practiseModel.options ?? [];
      if (!_canEdit) {
        for (int i = 0; i < _practiseList.length; i++) {
          final m = _practiseList[i];
          m.select = false;
          if (i == _practiseList.length - 1) {
            m.select = true;
          }
        }
        for (final m in _dataList) {
          m.isCorrect = false;
          m.select = false;
          if (m.title == practiseModel.answer) {
            m.select = true;
            m.isCorrect = true;
          }
        }
      }
    }
  }

  void _result({bool isCorrect = true}) {
    _submit = false;
    for (final m in _dataList) {
      m.select = false;
    }
    _update();
    _selectAnswerModel = null;
    if (_currentPage < _practiseList.length) {
      // 判断是否答题正确
      if (isCorrect) {
        _dataList = _practiseList[_currentPage].options ?? [];
        for (final m in _dataList) {
          m.select = false;
        }
        _update();
      }
    }
  }

  // 全对
  void _endAlert(data, {bool evenPairs = false}) {
    if (data.status == 2) {
      AnswerResultsPageSheet.show(1, integral: _integral, () {
        Get.close(0);
        // 判断是否最后答完有连对弹窗
        if (!evenPairs) {
          Get.close(0);
        }
        _result();
        // 答题完成后要对数据进行查看处理
        _canEdit = _completed == widget.item.total ? false : true;
        _currentPage = _practiseList.length - 1;
        if (!_canEdit) {
          var selectM;
          for (int i = 0; i < _practiseList.length; i++) {
            final m = _practiseList[i];
            m.select = false;
            if (i == _practiseList.length - 1) {
              m.select = true;
              selectM = m;
            }
          }
          for (final m in _dataList) {
            m.isCorrect = false;
            m.select = false;
            if (m.title == selectM?.answer) {
              m.select = true;
              m.isCorrect = true;
            }
          }
        }
      });
    }
  }

  // 是否连对
  void _evenPairs(data, {bool end = false}) {
    if ((data.pairsText ?? '').isNotEmpty) {
      bool showPairsTips = data.integral > 0 ? true : false;
      AnswerResultsPageSheet.show(2,
          pairsText: data.pairsText ?? '',
          integral: data.integral ?? 0,
          showPairsTips: showPairsTips, () {
            Get.close(0);
            Get.close(0);
            _result();
            if (end) {
              _endAlert(data, evenPairs: true);
            }
          });
    }
  }

  // TODO: Tap

  void _onPressed() async {
    if (!_canEdit || _selectAnswerModel == null) {
      return;
    }
    final model = _practiseList[_currentPage];
    final req = {'id': model.id, 'answer': _selectAnswerModel?.title ?? ''};
    final data = await CourseService.of.courseAnswer(req);
    if (data.id == null || data.status == null) {
      return;
    }
    _submit = true;
    _selectAnswerModel?.isCorrect = data.answer ?? false;
    _update();
    // 答题逻辑
    if (data.answer == false) {
      // 答题错误记录
      //_playSound('wrong');
    } else {
      // 答对继续下一题
      _practiseList[_currentPage].answer = data.answerStr ?? '';
      _completed += 1;
      if (_currentPage < _practiseList.length - 1) {
        _currentPage += 1;
      }
      //_playSound('correct');
    }
    // 结果弹窗
    String str = (data.answer ?? false) ? '泰裤辣！' : '不正确';
    AnswerResultsSheet.show(
        data.answer ?? false, data.answerStr ?? '', data.text ?? str,
            (isCorrect) {
          Get.close(0);
          _result(isCorrect: isCorrect);
        });
    // 答题正确的情况弹窗
    if (data.answer == true) {
      if (_currentPage == _practiseList.length - 1) {
        // 答题结束
        if ((data.pairsText ?? '').isNotEmpty) {
          _evenPairs(data, end: true);
        } else {
          _endAlert(data);
        }
      } else {
        // 答题未结束
        _evenPairs(data);
      }
    }
  }

  void _selectOnTap(model) {
    if (_canEdit) {
      model.select = true;
      _selectAnswerModel = model;
      for (final m in _dataList) {
        m.select = false;
        if (m.id == model.id) {
          m.select = true;
        }
      }
      _update();
    }
  }

  void _progressOnTap(int index) {
    if (_canEdit) return;
    _currentPage = index;
    for (final m in _practiseList) {
      m.select = false;
    }
    final model = _practiseList[index];
    model.select = true;
    _dataList = model.options ?? [];
    for (final m in _dataList) {
      m.select = false;
      m.isCorrect = false;
      if (m.title == model.answer) {
        m.select = true;
        m.isCorrect = true;
      }
    }
    _update();
  }

  // TODO: Build Widget

  @override
  void initState() {
    super.initState();
    _initData();
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
          if (_practiseList.isNotEmpty &&
              _currentPage < _practiseList.length)
            _buildPageWidget(_practiseList[_currentPage]),
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
                            text: '$_completed',
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
                    if (UserStore.of.isLogin)
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
                      )
                    else
                      SizedBox(width: 60.w)
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
                      _practiseList.length,
                          (index) {
                        final isCompleted = index < _completed;
                        final model = _practiseList[index];
                        return GestureDetector(
                          onTap: () {
                            _progressOnTap(index);
                          },
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: model.select == true
                                  ? ColorStyle.c557BF6
                                  : isCompleted
                                  ? '#557BF6'.hexColor.withOpacity(0.1)
                                  : '#333333'.hexColor.withOpacity(0.1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: model.select == true
                                    ? Colors.white
                                    : isCompleted
                                    ? '#557BF6'.hexColor
                                    : '#333333'.hexColor,
                              ),
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
    bool edit = _canEdit;
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Column(
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
          SizedBox(height: 20.w),
          GestureDetector(
            onTap: _onPressed,
            child: Container(
              height: 50.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _selectAnswerModel == null || !edit
                      ? ColorStyle.c333333.withOpacity(0.1)
                      : ColorStyle.c557BF6,
                  borderRadius: BorderRadius.all(Radius.circular(8.w))),
              child: Text(
                !edit ? '已完成' : '提交',
                style: TextStyle(
                    fontSize: 16.sp,
                    color: _selectAnswerModel == null
                        ? AppTheme.color_999999
                        : Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
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