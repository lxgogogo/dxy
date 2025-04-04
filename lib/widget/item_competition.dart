import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';

class CompetitionItem extends StatelessWidget {
  const CompetitionItem({
    super.key,
    required this.item,
  });

  final CompetitionBean item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.competitionDetail, arguments: item.id);
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
              style: TextStyle(
                color: Color(0xff2a2a2a),
                fontSize: 14.sp,
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
                Text(
                  '赛事期间',
                  style: TextStyle(
                    color: Color(0xff2a2a2a),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.px),
            Text(
              '${item.competition?.dayBegin != null ? DateFormat('yyyy-MM-dd HH:mm').format(item.competition!.dayBegin!) : ''}-${item.competition?.dayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.dayEnd!) : ''}',
              style: TextStyle(
                color: Color(0xff2a2a2a),
                fontSize: 12.sp,
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
                Text(
                  '主赛事期间',
                  style: TextStyle(
                    color: Color(0xff2a2a2a),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.px),
            Text(
              '${item.competition?.mainDayBegin != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.mainDayBegin!) : ''}-${item.competition?.mainDayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(item.competition!.mainDayEnd!) : ''}',
              style: TextStyle(
                color: Color(0xff2a2a2a),
                fontSize: 12.sp,
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
                Text(
                  '地点',
                  style: TextStyle(
                    color: Color(0xff2a2a2a),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.px),
            Text(
              item.competition?.place ?? '',
              style:  TextStyle(
                color: Color(0xff2a2a2a),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
