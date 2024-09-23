import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';

class GameCalendarPage extends StatefulWidget {
  const GameCalendarPage({super.key});

  @override
  State<GameCalendarPage> createState() => _GameCalendarPageState();
}

class _GameCalendarPageState extends State<GameCalendarPage> {
  calendar() {
    final DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    // final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final List<Widget> days = [];

    // 添加星期几标题
    days.addAll(['日', '一', '二', '三', '四', '五', '六'].map((day) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Center(
            child: Text(
          day,
          style: TextStyle(color: const Color(0xffAAB2C0)),
        )),
      );
    }).toList());

    // 找到本月第一天是星期几
    int startDay = DateTime(year, month, 1).weekday % 7;

    // 添加空白格子
    for (int i = 0; i < startDay; i++) {
      days.add(Container());
    }

    // 添加本月的每一天
    for (int day = 1; day <= daysInMonth; day++) {
      bool isSelected = false;
      if (day == 20) {
        isSelected = true;
      }
      days.add(CustomCalendarItem(day: day, selected: isSelected));
    }

    // 确保每行有 7 个元素
    while (days.length % 7 != 0) {
      days.add(Container());
    }

    // 创建日历表格
    return Table(
      children: [
        for (int i = 0; i < days.length ~/ 7; i++)
          TableRow(
            children: days.skip(i * 7).take(7).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.px),
          decoration: BoxDecoration(color: Colors.pink,
          borderRadius: BorderRadius.circular(12.px)),
          child: calendar(),
        )
      ],
    );
  }
}

class CustomCalendarItem extends StatelessWidget {
  final int day;
  final bool selected;

  CustomCalendarItem({required this.day, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
              color: selected ? Colors.white : const Color(0xff2c2c2c),
              fontSize: 16),
        ),
      ),
    );
  }
}
