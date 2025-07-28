import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_exercises_model.dart';
import 'package:holdem/model/course_model.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/widget/common_html/common_html_widget.dart';
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
  final _audioPlayer = AudioPlayer();
  List<CourseExerciseModel> _practiseList = [];
  List<CourseExerciseAnswerModel> _dataList = [];
  CourseExerciseAnswerModel? _selectAnswerModel;
  bool _submit = false;
  bool _isCorrectAnswer = false;
  // 按钮状态（true：点击后切换下一题，false：提交）
  bool _buttonState = false;
  int _currentPage = 0;
  int _progress = 0;
  int _integral = 0;
  int _completed = 0;
  int _totalPage = 0;
  bool _canEdit = true;
  String _answerStr = '';
  String _correctStr = '';

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
    } else if (_completed < _totalPage) {
      _currentPage = _completed;
    } else if (_completed == _totalPage) {
      _currentPage = _totalPage - 1;
    }
    _progress = _currentPage;
    final practiseData = data['practiseList'] ?? [];
    print('练习题数量:${practiseData.length}');
    print('_currentPage:$_currentPage');
    List<CourseExerciseModel> saveData = [];
    for (int i = 0; i < practiseData.length; i++) {
      final json = practiseData[i];
      CourseExerciseModel model = CourseExerciseModel.fromJson(json);
      if (!_canEdit) {
        model.completed = true;
      } else {
        model.completed = false;
        if (i < _currentPage) {
          model.completed = true;
        }
      }
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
        _result();
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
        _onContinue();
        Get.close(0);
        _result();
        if (end) {
          _endAlert(data, evenPairs: true);
        }
      });
    }
  }

  void _playSound(String name) async {
    await _audioPlayer.release(); // 每次播放前释放
    await _audioPlayer.play(AssetSource('sounds/$name.mp3'));
    await _audioPlayer.onPlayerStateChanged
        .firstWhere((state) => state == PlayerState.completed);
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
      _playSound('wrong');
    } else {
      // 答对继续下一题
      _practiseList[_currentPage].answer = data.answerStr ?? '';
      _practiseList[_currentPage].completed = true;
      _completed += 1;
      if (_currentPage < _practiseList.length - 1) {
        _currentPage += 1;
        _progress += 1;
      }
      EventBusUtil.of.fire(EventRefreshPractise(completed: _completed));
      _playSound('correct');
    }
    // 结果弹窗
    _answerStr = (data.answer ?? false) ? '泰裤辣！' : '不正确';
    _correctStr = data.answerStr ?? '';
    _isCorrectAnswer = data.answer ?? false;
    _buttonState = true;
    _update();
    // 答题正确的情况弹窗
    if (data.answer == true) {
      if (_currentPage == _practiseList.length - 1) {
        // 答题结束
        // 答题完成后要对数据进行查看处理
        _canEdit = _completed == widget.item.total ? false : true;
        _currentPage = _practiseList.length - 1;
        _progress = _currentPage;
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

  void _onContinue() {
    _buttonState = false;
    _result(isCorrect: _isCorrectAnswer);
  }

  void _selectOnTap(model) {
    // 没有答完+按钮状态是提交+该题未答
    final pModel = _practiseList[_currentPage];
    if (_canEdit && !_buttonState && pModel.completed == false) {
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
    if (_currentPage == index) {
      return;
    }
    final model = _practiseList[index];
    if (model.completed == false || (_canEdit && index > _completed)) {
      // 选中的是当前的答题
      if (index == _completed) {
        _currentPage = index;
        for (final m in _practiseList) {
          m.select = false;
        }
        _dataList = model.options ?? [];
        _onContinue();
      }
      return;
    }
    _onContinue();
    _currentPage = index;
    for (final m in _practiseList) {
      m.select = false;
    }
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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _progress / _totalPage;
    if (!_canEdit) {
      progress = 1.0;
    }
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
          if (_practiseList.isNotEmpty && _currentPage < _practiseList.length)
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
                Container(
                  width: double.infinity,
                  height: 4.w,
                  margin: EdgeInsets.symmetric(vertical: 8.w),
                  decoration: BoxDecoration(
                    color: '#333333'.hexColor.withOpacity(0.05),
                    borderRadius: BorderRadius.all(Radius.circular(2.w)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            width: !_canEdit
                                ? constraints.maxWidth
                                : progress * constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: '#557BF6'.hexColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.w)),
                            )),
                      );
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Wrap(
                    spacing: 8.w,
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
                              color: model.completed == false &&
                                      _currentPage == index &&
                                      _buttonState == false
                                  ? ColorStyle.c333333.withOpacity(0.3)
                                  : model.select == true ||
                                          (_buttonState &&
                                              _currentPage - 1 == index &&
                                              _isCorrectAnswer && _canEdit)
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
                                color: (model.completed == false &&
                                            _currentPage == index &&
                                            _buttonState == false) ||
                                        model.select == true ||
                                        (_buttonState &&
                                            _currentPage - 1 == index &&
                                            _isCorrectAnswer && _canEdit)
                                    ? Colors.white
                                    : isCompleted
                                        ? AppTheme.color_557BF6
                                        : AppTheme.color_666666,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((model.title ?? '').isNotEmpty)
            Row(
              children: [
                Text(
                  model.title ?? '',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                )
              ],
            ),
          SizedBox(height: 10.w),
          CommonHtmlWidget(content: model.content ?? ''),
          SizedBox(height: 50.w),
          Wrap(
            runSpacing: 10.w,
            children: [
              ..._dataList.map((e) {
                return _buildButtonWidget(e);
              })
            ],
          ),
          if (_buttonState && _canEdit) ...[
            SizedBox(height: 20.w),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _isCorrectAnswer
                          ? Assets.courses.iconCoursesTrue.path
                          : Assets.courses.iconCoursesWrong.path,
                      width: 16.w,
                      height: 16.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      _answerStr,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: _isCorrectAnswer
                              ? AppTheme.color_39B423
                              : ColorStyle.cFF3333,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (!_isCorrectAnswer) ...[
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 5.w),
                        Text('正确答案：$_correctStr',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorStyle.cFF3333,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                  )
                ]
              ],
            )
          ],
          SizedBox(height: 20.w),
          Stack(
            children: [
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
                    !edit || _practiseList[_currentPage].completed == true
                        ? '已完成'
                        : '提交',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: !edit ||
                                _practiseList[_currentPage].completed == true
                            ? ColorStyle.c333333
                            : _selectAnswerModel == null
                                ? AppTheme.color_999999
                                : Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (_buttonState && _canEdit)
                GestureDetector(
                  onTap: _onContinue,
                  child: Container(
                    height: 50.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _isCorrectAnswer
                            ? AppTheme.color_39B423
                            : ColorStyle.cFF3333,
                        borderRadius: BorderRadius.all(Radius.circular(8.w))),
                    child: Text(
                      _isCorrectAnswer ? '继续' : '重试',
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          )
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
    final pModel = _practiseList[_currentPage];
    if (pModel.completed == true || !_canEdit) {
      if (select && !_submit) {
        borderColor = AppTheme.color_39B423;
        bgColor = AppTheme.color_39B423.withOpacity(0.1);
        titleColor = AppTheme.color_39B423;
        shadowColor = '#39B423'.hexColor.withOpacity(0.1);
      }
    } else {
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
    }

    return GestureDetector(
        onTap: () {
          _selectOnTap(model);
        },
        child: Container(
          height: 46.w,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
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
