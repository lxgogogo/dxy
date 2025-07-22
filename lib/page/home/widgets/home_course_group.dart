import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../stores/user_store.dart';
import '../../../widget/common_image.dart';
import '../../../widget/common_operations_sheet.dart';
import '../home_screen.dart';

class HomeCourseGroup extends StatelessWidget {
  const HomeCourseGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.w),
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Column(
            children: [
              GestureDetector(
                onTap: () => _onSelectCourse(controller),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.courseGroup?.label ?? '',
                        style: TextStyle(
                          color: '#333333'.hexColor,
                          fontSize: 18.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      Assets.svg.iconArrowDown,
                      width: 20.w,
                      height: 20.w,
                      color: '#666666'.hexColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Column(
                spacing: 12.w,
                children: controller.courseItems
                    .map(
                      (e) => GestureDetector(
                        onTap: () => controller.toCourseDetail(e),
                        child: Container(
                          height: 94.w,
                          decoration: BoxDecoration(
                            color: '#F9FCFF'.hexColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.all(6.w),
                          child: Row(
                            spacing: 6.w,
                            children: [
                              CommonImage.net(
                                imageUrl: e.cover ?? '',
                                radius: 8.r,
                                width: 136.w,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      e.title ?? '',
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.w),
                                    Text(
                                      e.des ?? '',
                                      style: TextStyle(
                                        color: '#666666'.hexColor,
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSelectCourse(HomeController controller) {
    int? selectedIndex;
    if (controller.courseGroup != null) {
      selectedIndex = controller.courseGroups.indexWhere(
        (e) => e.value?.des == controller.courseGroup!.value?.des,
      );
    }
    showCommonOperationsSheet(
        maxHeight: 478.w,
        selectedIndex: selectedIndex,
        items: controller.courseGroups.map((e) => e.label ?? '').toList(),
        onSelectItem: (int index) {
          final model = controller.courseGroups[index];
          controller.onChangeType(model);
        },
        itemBuilder: (int index) {
          final item = controller.courseGroups[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.value?.icon?.isNotEmpty == true)
                CommonImage.net(
                  imageUrl: item.value?.icon ?? '',
                  width: 16.w,
                  height: 16.w,
                ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  item.label ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: selectedIndex == index ? '#333333'.hexColor : '#666666'.hexColor,
                    fontWeight: selectedIndex == index ? FontWeight.w500 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        overflowWidget: !UserStore.of.isLogin
            ? Container(
                width: 1.sw,
                height: 478.w - 60.w,
                margin: EdgeInsets.only(top: 60.w),
                color: Colors.white.withOpacity(0.9),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/courses/icon_courses_not_login.png',
                  width: 128.w,
                  fit: BoxFit.cover,
                ))
            : null);
  }
}
