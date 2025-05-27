import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'select_courses_controller.dart';

class SelectCoursesPage extends StatefulWidget {
  const SelectCoursesPage({Key? key}) : super(key: key);

  @override
  State<SelectCoursesPage> createState() => _SelectCoursesPageState();
}

class _SelectCoursesPageState extends State<SelectCoursesPage> {
  final SelectCoursesController controller = Get.put(SelectCoursesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.arrowBack(context,
          title: '初次选择任务页面'),
      body: Container()
    );
  }

  @override
  void dispose() {
    Get.delete<SelectCoursesController>();
    super.dispose();
  }
}