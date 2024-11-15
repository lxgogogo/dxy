import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/page/index/competition_detail_page.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/utils.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/tab_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CompetitionCalendarPage extends StatefulWidget {
  const CompetitionCalendarPage({super.key});

  @override
  State<CompetitionCalendarPage> createState() => _CompetitionCalendarPageState();
}

class _CompetitionCalendarPageState extends State<CompetitionCalendarPage> {
  List<CompetitionBean> _items = [];

  List<CompetitionBean> _selectedEvents = [];
  late DateTime _toDay;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    _toDay = DateTime.now();
    _focusedDay = _toDay;
    _selectedDay = _focusedDay;
    super.initState();
    reqData();
  }

  List<CompetitionBean> _getEventsForDay(DateTime day) {
    final List<CompetitionBean> events = [];
    if (_items.isNotEmpty) {
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        final dayBegin = item.competition?.dayBegin;
        final dayEnd = item.competition?.dayEnd;
        if (dayBegin != null && dayEnd != null) {
          if ((day.isAfter(dayBegin) || isSameDay(day, dayBegin)) && (day.isBefore(dayEnd) || isSameDay(day, dayEnd))) {
            events.add(item);
          }
        }
      }
    }
    return events;
  }

  int _getEventCountForDay(DateTime day) {
    int count = 0;
    if (_items.isNotEmpty) {
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        final dayBegin = item.competition?.dayBegin;
        final dayEnd = item.competition?.dayEnd;
        if (dayBegin != null && dayEnd != null) {
          if (day.isAfter(dayBegin) && day.isBefore(dayEnd)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  bool? _getSingleDayAvailable(DateTime day) {
    bool? available;
    if (_items.isNotEmpty) {
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        final dayBegin = item.competition?.dayBegin;
        final dayEnd = item.competition?.dayEnd;
        if (dayBegin != null && dayEnd != null) {
          if (isSameDay(dayBegin, day) && isSameDay(day, dayEnd)) {
            if (day.isAfter(dayBegin) && day.isBefore(dayEnd)) {
              available = day.isAfter(_toDay);
            } else {
              available = false;
            }
          }
        }
      }
    }
    return available;
  }

  reqData() {
    if (_selectedDay == null) return;
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'searchMonth': DateFormat('yyyy-MM').format(_focusedDay),
        'categoryAlias': 'competition',
      }
    }, (data) {
      final dataList = List<CompetitionBean>.from(
        (data?['list'] as List? ?? []).map(
          (e) => CompetitionBean.fromJson(e),
        ),
      );
      _items = dataList;
      _selectedEvents = _getEventsForDay(_selectedDay!);
      setState(() {});
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: GestureDetector(
        onTap: () {
          _selectedDay = null;
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '德州赛事',
              style: TextStyle(
                color: const Color(0xff2c2c2c),
                fontSize: 16.px,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Image.asset(
                'assets/images/back.png',
                width: 22.px,
                height: 22.px,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.px),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TableCalendar<Event>(
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    onPageChanged: (focusedDay) {
                      if (_focusedDay.month != focusedDay.month) {
                        _focusedDay = focusedDay;
                        reqData();
                      } else {
                        _focusedDay = focusedDay;
                      }
                    },
                    calendarBuilders: CalendarBuilders(
                      prioritizedBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                        final isWeekend = [DateTime.saturday, DateTime.sunday].contains(day.weekday);
                        final textColor = isSameDay(kToday, day)
                            ? const Color(0xff249cfc)
                            : isWeekend
                                ? const Color(0xffaab2c0)
                                : const Color(0xff2c2c2c);
                        final isPastDay = _toDay.isAfter(day);
                        final isSelectedDay = isSameDay(_selectedDay, day);
                        final eventCount = _getEventCountForDay(day);
                        final isSingleDayAvailable = _getSingleDayAvailable(day);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            border: eventCount > 0
                                ? Border(
                                    bottom: BorderSide(
                                      color: isSingleDayAvailable != null
                                          ? Colors.transparent
                                          : isPastDay
                                              ? const Color(0xffb0afa7)
                                              : const Color(0xffd9001b),
                                      width: 3,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: eventCount > 1 ? const Color(0xfff3f6fa) : null,
                                  border: isSelectedDay ? Border.all(color: const Color(0xff3c7bfa), width: 2) : null,
                                ),
                                child: Text(
                                  DateFormat('d').format(day),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSingleDayAvailable != null)
                                Positioned(
                                  bottom: 4.px,
                                  child: Container(
                                    width: 4.px,
                                    height: 4.px,
                                    decoration: ShapeDecoration(
                                      color: isSingleDayAvailable == true
                                          ? const Color(0xffd9001b)
                                          : const Color(0xffb0afa7),
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4.px),
                    margin: EdgeInsets.symmetric(vertical: 16.px),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '赛事详情',
                      style: TextStyle(
                        color: Color(0xff2c2c2c),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (_selectedEvents.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final item = _selectedEvents[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(CompetitionDetailPage(id: item.id));
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.px),
                            padding: EdgeInsets.symmetric(horizontal: 14.px, vertical: 12.px),
                            decoration: BoxDecoration(
                              color: const Color(0xfff4f9ff),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  item.title ?? '',
                                  style: const TextStyle(
                                    color: Color(0xff2a2a2a),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10.px),
                                Row(
                                  children: [
                                    Container(
                                      width: 5.px,
                                      height: 14.px,
                                      margin: EdgeInsets.only(right: 5.5.px),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: const Color(0xff249cfc),
                                      ),
                                    ),
                                    const Text(
                                      '赛事期间',
                                      style: TextStyle(
                                        color: Color(0xff2a2a2a),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.px),
                                Text(
                                  '${item.competition?.dayBegin != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.dayBegin!) : ''}-${item.competition?.dayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.dayEnd!) : ''}',
                                  style: const TextStyle(
                                    color: Color(0xff2a2a2a),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 10.px),
                                Row(
                                  children: [
                                    Container(
                                      width: 5.px,
                                      height: 14.px,
                                      margin: EdgeInsets.only(right: 5.5.px),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: const Color(0xff249cfc),
                                      ),
                                    ),
                                    const Text(
                                      '主赛事期间',
                                      style: TextStyle(
                                        color: Color(0xff2a2a2a),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.px),
                                Text(
                                  '${item.competition?.mainDayBegin != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.mainDayBegin!) : ''}-${item.competition?.mainDayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.mainDayEnd!) : ''}',
                                  style: const TextStyle(
                                    color: Color(0xff2a2a2a),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 10.px),
                                Row(
                                  children: [
                                    Container(
                                      width: 5.px,
                                      height: 14.px,
                                      margin: EdgeInsets.only(right: 5.5.px),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: const Color(0xff249cfc),
                                      ),
                                    ),
                                    const Text(
                                      '地点',
                                      style: TextStyle(
                                        color: Color(0xff2a2a2a),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.px),
                                Text(
                                  item.competition?.place ?? '',
                                  style: const TextStyle(
                                    color: Color(0xff2a2a2a),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _selectedEvents.length,
                    ),
                  )
                else
                  SliverFillViewport(
                    viewportFraction : 0.375,
                    padEnds : false,
                    delegate: SliverChildListDelegate([
                      const NoDataView(text: '暂无赛事'),
                    ]),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
