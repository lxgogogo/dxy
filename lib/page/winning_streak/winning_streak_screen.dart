import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/course_punch_model.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/tab_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../gen/assets.gen.dart';
import '../../model/course_model.dart';
import '../../routes/app_pages.dart';
import '../../routes/app_routes_utils.dart';
import '../../services/course_service.dart';
import '../../utils/log_util.dart';
import '../../utils/toast_utils.dart';
import '../../widget/no_network.dart';

part 'winning_streak_binding.dart';

part 'winning_streak_controller.dart';

class WinningStreakScreen extends StatefulWidget {
  const WinningStreakScreen({Key? key}) : super(key: key);

  @override
  State<WinningStreakScreen> createState() => _WinningStreakScreenState();
}

class _WinningStreakScreenState extends State<WinningStreakScreen> {
  final WinningStreakController controller = Get.put(WinningStreakController());
  DateTime _focusedDay = DateTime.now();

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
                    Obx(() {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            Assets.svg.iconCourseHot,
                            width: 28.w,
                            height: 28.w,
                          ),
                          SizedBox(width: 12.w),
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
                      );
                    }),
                    SizedBox(height: 12.w),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: '#F9FCFF'.hexColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '今天就剩下4个小时啦，别放弃你的连胜战绩去完成一个课程的知识以及练习！',
                          children: [
                            TextSpan(
                              text: '延续连胜',
                              style: TextStyle(
                                color: '#557BF6'.hexColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                        style: TextStyle(
                          color: '#666666'.hexColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
      child: Container(
        decoration: BoxDecoration(
          color: '#F9FCFF'.hexColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: TableCalendar(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_focusedDay.add(Duration(days: 5)), day),
          rangeStartDay: _focusedDay.subtract(Duration(days: 1)),
          rangeEndDay: _focusedDay.add(Duration(days: 3)),
          rangeSelectionMode: RangeSelectionMode.disabled,
          holidayPredicate: (day) => isSameDay(_focusedDay.add(Duration(days: 2)), day),
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          locale: 'zh',
          rowHeight: 28.w + 12,
          daysOfWeekHeight: 42.w,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayTextStyle: TextStyle(),
            rangeStartDecoration: BoxDecoration(
              color: '#F69555'.hexColor,
              borderRadius: BorderRadius.circular(40.r),
            ),
            rangeStartTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            rangeHighlightColor: '#F69555'.hexColor.withOpacity(0.2),
            rangeEndDecoration: BoxDecoration(
              color: '#F69555'.hexColor,
              borderRadius: BorderRadius.circular(40.r),
            ),
            rangeEndTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            todayDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.transparent, width: 2.w),
                bottom: BorderSide(color: Colors.red, width: 2.w),
              ),
            ),
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
            selectedBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.svg.bgDayDecoration,
                      height: 28.w,
                    ),
                    Text(
                      DateFormat('d').format(day),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
            holidayBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  padding: EdgeInsets.all(3.r),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: '#557BF6'.hexColor.withOpacity(0.2),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: '#557BF6'.hexColor,
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
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<WinningStreakController>();
    super.dispose();
  }
}
