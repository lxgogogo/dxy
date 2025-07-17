import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/common_image.dart';

import '../../../model/select_courses_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/course_service.dart';

part 'select_courses_binding.dart';

part 'select_courses_controller.dart';

class SelectCoursesScreen extends StatefulWidget {
  const SelectCoursesScreen({Key? key}) : super(key: key);

  @override
  State<SelectCoursesScreen> createState() => _SelectCoursesScreenState();
}

class _SelectCoursesScreenState extends State<SelectCoursesScreen> {
  final SelectCoursesController controller = Get.put(SelectCoursesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.color_F7F8FC,
      appBar: CommonAppBar.arrowBack(context, title: '请选择一个最符合的描述'),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.w),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.w),
                itemCount: controller.courseTypes.length,
                itemBuilder: (context, int index) => _buildListItemWidget(
                  index,
                  controller.courseTypes[index],
                ),
                separatorBuilder: (_, __) => SizedBox(height: 16.w),
              ),
            ),
            GestureDetector(
              onTap: controller.onPressed,
              child: Container(
                height: 48.w,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.selectedIndex.value == -1 ? '#333333'.hexColor.withOpacity(0.1) : null,
                  gradient: controller.selectedIndex.value == -1
                      ? null
                      : LinearGradient(
                          colors: [
                            '#557BF6'.hexColor,
                            '#84BCF9'.hexColor,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '继续',
                  style: TextStyle(
                    color: controller.selectedIndex.value == -1 ? '#999999'.hexColor : Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.w)
          ],
        );
      }),
    );
  }

  Widget _buildListItemWidget(int index, SelectCoursesModel e) {
    return GestureDetector(
      onTap: () {
        controller.selectOnTap(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: Border.all(
            color: controller.selectedIndex.value == index ? ColorStyle.c557BF6 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            CommonImage.net(
              imageUrl: e.icon ?? '',
              width: 32.w,
              height: 32.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                e.des ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorStyle.c333333,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
