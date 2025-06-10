import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/course_punch_model.dart';
import 'package:holdem/utils/utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/tab_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../gen/assets.gen.dart';
import '../../services/course_service.dart';
import '../../utils/log_util.dart';

part 'winning_streak_binding.dart';

part 'winning_streak_controller.dart';

class WinningStreakScreen extends StatefulWidget {
  const WinningStreakScreen({Key? key}) : super(key: key);

  @override
  State<WinningStreakScreen> createState() => _WinningStreakScreenState();
}

class _WinningStreakScreenState extends State<WinningStreakScreen> {
  final WinningStreakController controller = Get.put(WinningStreakController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.arrowBack(
        context,
        title: '连胜',
      ),
      backgroundColor: '#F7F8FC'.hexColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: '#58A5FF'.hexColor.withOpacity(0.1),
                        blurRadius: 8.63.r,
                        offset: Offset(0, 4.32.w),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          switch (controller.detailBean.value?.status) {
                            1 => Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: SvgPicture.asset(
                                  Assets.svg.iconWinningStatus1,
                                  width: 28.w,
                                  height: 28.w,
                                ),
                              ),
                            2 => Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: SvgPicture.asset(
                                  Assets.svg.iconWinningStatus2,
                                  width: 28.w,
                                  height: 28.w,
                                ),
                              ),
                            3 => Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: SvgPicture.asset(
                                  Assets.svg.iconWinningStatus3,
                                  width: 28.w,
                                  height: 28.w,
                                ),
                              ),
                            _ => const SizedBox(),
                          },
                          Text(
                            '${controller.detailBean.value?.winnerDay ?? 0}',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '天连胜啦！',
                            style: TextStyle(
                              color: '#666666'.hexColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.w),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: '#F9FCFF'.hexColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          controller.detailBean.value?.tipText ?? '',
                          style: TextStyle(
                            color: '#666666'.hexColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
              SizedBox(height: 16.w),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: '#58A5FF'.hexColor.withOpacity(0.1),
                      blurRadius: 8.63.r,
                      offset: Offset(0, 4.32.w),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '连胜目标！',
                      style: TextStyle(
                        color: '#000000'.hexColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Obx(() {
                          final targets = controller.detailBean.value?.target ?? [];
                          final winnerDay = controller.detailBean.value?.winnerDay ?? 0;
                          if (targets.isEmpty) return const SizedBox();

                          double progressWidth = 0;
                          final totalWidth = constraints.maxWidth;

                          if (winnerDay <= targets.first) {
                            // 小于等于第一个目标
                            progressWidth = 0;
                          } else if (winnerDay >= targets.last) {
                            // 大于等于最后一个目标
                            progressWidth = totalWidth;
                          } else {
                            // 在两个目标之间
                            for (int i = 0; i < targets.length - 1; i++) {
                              final start = targets[i];
                              final end = targets[i + 1];
                              if (winnerDay == start) {
                                progressWidth = i * totalWidth / (targets.length - 1);
                                break;
                              } else if (winnerDay > start && winnerDay < end) {
                                final percent = (winnerDay - start) / (end - start);
                                progressWidth = (i + percent) * totalWidth / (targets.length - 1);
                                break;
                              }
                            }
                          }

                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  width: double.infinity,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: '#333333'.hexColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: progressWidth,
                                    color: '#557BF6'.hexColor,
                                  ),
                                ),
                              ),
                              // 目标点
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(targets.length, (index) {
                                  final isReached = winnerDay >= targets[index];
                                  return Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isReached ? '#557BF6'.hexColor : Colors.white,
                                      border: Border.all(
                                        color: isReached ? '#557BF6'.hexColor : '#999999'.hexColor,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${targets[index]}',
                                      style: TextStyle(
                                        color: isReached ? Colors.white : '#999999'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: '#58A5FF'.hexColor.withOpacity(0.1),
              blurRadius: 8.63.r,
              offset: Offset(0, 4.32.w),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '连胜日历',
              style: TextStyle(
                color: '#000000'.hexColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.w),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(Assets.svg.iconCourseCalendar, width: 16.w, height: 16.w),
                      SizedBox(width: 8.w),
                      Text.rich(
                        TextSpan(
                          text: '总打卡',
                          children: [
                            TextSpan(
                              text: ' ${controller.detailBean.value?.punchTotal ?? 0} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: '天'),
                          ],
                        ),
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(Assets.svg.iconCourseIntegral, width: 16.w, height: 16.w),
                      SizedBox(width: 8.w),
                      Text.rich(
                        TextSpan(
                          text: '积分补卡',
                          children: [
                            TextSpan(
                              text: ' ${controller.detailBean.value?.integralTotal ?? 0} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: '次'),
                          ],
                        ),
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            Container(
              decoration: BoxDecoration(
                color: '#F9FCFF'.hexColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: controller.focusedDay.value,
                // selectedDayPredicate: (day) => isSameDay(controller._focusedDay.value.add(Duration(days: 1)), day),
                // rangeStartDay: controller._focusedDay.value.subtract(Duration(days: 10)),
                // rangeEndDay: controller._focusedDay.value.add(Duration(days: 10)),
                rangeSelectionMode: RangeSelectionMode.disabled,
                // holidayPredicate: (day) => isSameDay(controller._focusedDay.value.add(Duration(days: 2)), day),
                onPageChanged: (DateTime focusedDay) {
                  controller.focusedDay.value = focusedDay;
                  controller.loadData(focusedDay);
                },
                locale: 'zh',
                rowHeight: 28.w + 12,
                daysOfWeekHeight: 42.w,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  // rangeStartDecoration: BoxDecoration(
                  //   // color: '#557BF6'.hexColor.withOpacity(0.1),
                  //   borderRadius: BorderRadius.circular(40.r),
                  // ),
                  // rangeStartTextStyle: TextStyle(
                  //   color: Colors.white,
                  //   fontSize: 12.sp,
                  //   fontWeight: FontWeight.w600,
                  // ),
                  // rangeHighlightColor: '#557BF6'.hexColor.withOpacity(0.1),
                  // rangeEndDecoration: BoxDecoration(
                  //   // color: '#557BF6'.hexColor.withOpacity(0.1),
                  //   borderRadius: BorderRadius.circular(40.r),
                  // ),
                  // rangeEndTextStyle: TextStyle(
                  //   color: Colors.white,
                  //   fontSize: 12.sp,
                  //   fontWeight: FontWeight.w600,
                  // ),
                  // todayDecoration: BoxDecoration(
                  //   border: Border(
                  //     top: BorderSide(color: Colors.transparent, width: 2.w),
                  //     bottom: BorderSide(color: '557BF6'.hexColor, width: 2.w),
                  //   ),
                  // ),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  leftChevronIcon: SvgPicture.asset(
                    Assets.svg.iconCalendarLeft,
                    width: 16.w,
                    height: 16.w,
                  ),
                  rightChevronIcon: SvgPicture.asset(
                    Assets.svg.iconCalendarRight,
                    width: 16.w,
                    height: 16.w,
                  ),
                  titleTextStyle: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: '#999999'.hexColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  weekendStyle: TextStyle(
                    color: '#999999'.hexColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  dowTextFormatter: (DateTime date, dynamic locale) {
                    return DateFormat.E(locale).format(date).replaceAll('周', '');
                  },
                ),
                calendarBuilders: CalendarBuilders(
                  prioritizedBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                    final today = DateTime.now();
                    final practiseList = controller.detailBean.value?.practiseList ?? [];
                    final bool isToday = DateUtils.isSameDay(day, today);
                    final bool isSignInDay = _isSignInDay(day, practiseList);
                    final bool isFreezingDay = _isFreezingDay(day, practiseList);
                    final bool isNextDay = _isNextDay(day, practiseList);
                    final bool isRangeStart = _isSignInRangeStart(day, practiseList);
                    final bool isRangeEnd = _isSignInRangeEnd(day, practiseList);
                    if (isSignInDay) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        child: Container(
                          height: 28.w,
                          decoration: BoxDecoration(
                            borderRadius: isRangeStart
                                ? BorderRadius.horizontal(left: Radius.circular(40.r))
                                : isRangeEnd
                                    ? BorderRadius.horizontal(right: Radius.circular(40.r))
                                    : BorderRadius.zero,
                            color: '#557BF6'.hexColor.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isToday) SizedBox(height: 2.w),
                              Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSignInDay ? '#557BF6'.hexColor : '#333333'.hexColor,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  width: 18.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(
                                    color: '#557BF6'.hexColor,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    } else if (isFreezingDay) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        child: Container(
                          height: 28.w,
                          decoration: BoxDecoration(
                            borderRadius: isRangeStart
                                ? BorderRadius.horizontal(left: Radius.circular(40.r))
                                : isRangeEnd
                                    ? BorderRadius.horizontal(right: Radius.circular(40.r))
                                    : BorderRadius.zero,
                            color: '#557BF6'.hexColor.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            padding: EdgeInsets.all(3.r),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: '#999999'.hexColor.withOpacity(0.1),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: '#333333'.hexColor.withOpacity(0.1),
                              ),
                              child: Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (isNextDay) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        child: Container(
                          height: 28.w,
                          alignment: Alignment.center,
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: '#557BF6'.hexColor,
                              borderRadius: BorderRadius.circular(1.55.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isToday) SizedBox(height: 2.w),
                                Text(
                                  DateFormat('d').format(day),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    width: 18.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    if (isToday) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        child: Container(
                          height: 28.w,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isToday) SizedBox(height: 2.w),
                              Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSignInDay ? '#557BF6'.hexColor : '#333333'.hexColor,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  width: 18.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(
                                    color: '#557BF6'.hexColor,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    Get.delete<WinningStreakController>();
    super.dispose();
  }

  bool _isSignInDay(DateTime day, List<PractiseList> practiseList) => practiseList.any(
        (e) => DateUtils.isSameDay(day, e.punchDate) && e.type == 1,
      );

  bool _isFreezingDay(DateTime day, List<PractiseList> practiseList) => practiseList.any(
        (e) => DateUtils.isSameDay(day, e.punchDate) && e.type == 2,
      );

  bool _isNextDay(DateTime day, List<PractiseList> practiseList) => practiseList.any(
        (e) => DateUtils.isSameDay(day, e.punchDate) && e.type == 3,
      );

  /// 获取最早的签到日期
  DateTime? _getFirstSignInDate(List<PractiseList> practiseList) {
    try {
      return practiseList
          .where((e) => e.type == 1 && e.punchDate != null)
          .map((e) => e.punchDate!)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    } catch (e) {
      return null;
    }
  }

  /// 获取最晚的签到日期
  DateTime? _getLastSignInDate(List<PractiseList> practiseList) {
    try {
      return practiseList
          .where((e) => e.type == 1 && e.punchDate != null)
          .map((e) => e.punchDate!)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    } catch (e) {
      return null;
    }
  }

  /// 判断是否是签到范围的开始日期
  bool _isSignInRangeStart(DateTime day, List<PractiseList> practiseList) {
    final firstDate = _getFirstSignInDate(practiseList);
    return firstDate != null && DateUtils.isSameDay(day, firstDate);
  }

  /// 判断是否是签到范围的结束日期
  bool _isSignInRangeEnd(DateTime day, List<PractiseList> practiseList) {
    final lastDate = _getLastSignInDate(practiseList);
    return lastDate != null && DateUtils.isSameDay(day, lastDate);
  }
}
