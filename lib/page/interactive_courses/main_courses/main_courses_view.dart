import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';

import 'main_courses_controller.dart';

class MainCoursesPage extends StatefulWidget {
  const MainCoursesPage({Key? key}) : super(key: key);

  @override
  State<MainCoursesPage> createState() => _MainCoursesPageState();
}

class _MainCoursesPageState extends State<MainCoursesPage> {
  final MainCoursesController controller = Get.put(MainCoursesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.coursesExercises);
              },
              child: Text('德学院'),
            )
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          Text('德学院'),
          Text('德学院')
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Get.toNamed(Routes.selectCourses);
          },
          child: Text(
            '进入课程选择',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red
            ),
          )
        ),
      )
    );
  }

  @override
  void dispose() {
    Get.delete<MainCoursesController>();
    super.dispose();
  }
}