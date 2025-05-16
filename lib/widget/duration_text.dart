import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DurationText extends StatelessWidget {
  final int durationInSeconds;

  const DurationText({super.key, required this.durationInSeconds});

  String formatDuration(int seconds) {
    int hours = (seconds ~/ 3600);
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(secs)}';
    } else {
      return '${_twoDigits(minutes)}:${_twoDigits(secs)}';
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(durationInSeconds),
      style: TextStyle(
        color: Colors.white,
        fontSize: 10.sp,
      ),
    );
  }
}