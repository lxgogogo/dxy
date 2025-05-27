import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            Text('德学院')
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          Text('德学院'),
          Text('德学院')
        ],
      ),
      body: Container()
    );
  }

  @override
  void dispose() {
    Get.delete<MainCoursesController>();
    super.dispose();
  }
}