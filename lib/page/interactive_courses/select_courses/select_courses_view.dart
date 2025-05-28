import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/button.dart';
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
      backgroundColor: AppTheme.color_F7F8FC,
      appBar: CommonAppBar.arrowBack(context,
          title: '请选择一个最符合的描述'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.w),
          Expanded(
            child: Obx(() => SingleChildScrollView(
                child: Wrap(
                  children: [
                    ...controller.dataList.map((e) {
                      return _buildListItemWidget(e);
                    })
                  ],
                )
            )),
          ),
          SizedBox(height: 20.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomButton(
              onPressed: controller.onPressed,
              disable: false,
              showOpacityAnimation: true,
              textColor: Colors.white,
              height: 50.w,
              radius: 8.w,
              title: '继续',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 80.w)
        ],
      )
    );
  }

  @override
  void dispose() {
    Get.delete<SelectCoursesController>();
    super.dispose();
  }

  Widget _buildListItemWidget(e) {
    return GestureDetector(
      onTap: () {
        controller.selectOnTap(e);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w).copyWith(top: 0),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.w)),
              border: Border.all(
                  width: 1.w,
                  color: (e.select ?? false)  ? ColorStyle.c557BF6 : Colors.white
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    e.icon ?? '',
                    width: 32.w,
                    height: 32.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    e.name ?? '',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.c333333
                    ),
                  )
                ],
              ),
              SizedBox(height: 11.w),
              Text(
                e.content ?? '',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.color_666666
                ),
              )
            ],
          )
      ),
    );
  }
}