import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../model/report_type_model.dart';

class ReportSheet extends StatelessWidget {
  final List<ReportTypeModel> reportTypes;
  final Function(int index) onReport;

  const ReportSheet({
    super.key,
    required this.reportTypes,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            child: Text(
              '举报',
              style: TextStyle(
                color: '#2c2c2c'.hexColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SafeArea(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      onReport.call(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: '#E6E6E6'.hexColor)),
                      ),
                      child: Text(
                        reportTypes[index].label ?? '',
                        style: TextStyle(
                          color: '#3B5078'.hexColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: reportTypes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
