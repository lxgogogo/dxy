import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/services/course_service.dart';
import 'package:holdem/utils/toast_utils.dart';

class CourseChallengeAlert {
  static show(id, status,
      {String title = '',
      String content = '',
      Function? callBack,
      Function? errorBack}) {
    Get.dialog(CourseChallengeWidget(
        id: id,
        status: status,
        title: title,
        content: content,
        callBack: callBack));
  }
}

class CourseChallengeWidget extends StatefulWidget {
  final int id;
  final int status;
  final String title;
  final String content;
  final Function? callBack;
  final Function? errorBack;
  const CourseChallengeWidget(
      {super.key,
      required this.id,
      required this.status,
      required this.content,
      required this.title,
      this.callBack,
      this.errorBack});

  @override
  State<StatefulWidget> createState() {
    return _CourseChallengeWidgetState();
  }
}

class _CourseChallengeWidgetState extends State<CourseChallengeWidget> {
  void _courseChallenge() {
    CourseService.of.courseChallenge(widget.id).then((value) {
      if (value.isSuccess) {
        if (value.data == null) {
          Navigator.of(context).pop();
          ToastUtils.showToast('当前课程内容已被更改,请稍后再试');
          if (widget.errorBack != null) {
            widget.errorBack!();
          }
        } else {
          ToastUtils.showToast('已完成挑战');
          Navigator.of(context).pop();
          if (widget.callBack != null) {
            widget.callBack!();
          }
        }
      } else {
        ToastUtils.showToast(value.msg);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 518.w,
        margin: EdgeInsets.only(left: 32.w, right: 32.w),
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
            color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 24.w),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 16.w,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.w),
            Expanded(
                child: SingleChildScrollView(
                    child: Text(
              widget.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 14.w,
                fontWeight: FontWeight.w500,
              ),
            ))),
            SizedBox(height: 20.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.status != 1) ...[
                  InkWell(
                    onTap: () {
                      _courseChallenge();
                    },
                    child: Container(
                      width: 96.w,
                      height: 36.w,
                      decoration: ShapeDecoration(
                        color: '#333333'.hexColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '直接完成',
                        style: TextStyle(
                          color: '#333333'.hexColor.withOpacity(0.7),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w)
                ],
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 96.w,
                    height: 36.w,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(1.00, 0.00),
                        end: Alignment(-1, 0),
                        colors: [
                          Color(0xFF84BCF9),
                          Color(0xFF557BF6),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '关闭',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.w)
          ],
        ),
      ),
    );
  }
}
