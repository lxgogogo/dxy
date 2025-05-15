import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'revise_account_controller.dart';

class ReviseAccountPage extends StatefulWidget {
  const ReviseAccountPage({Key? key}) : super(key: key);

  @override
  State<ReviseAccountPage> createState() => _ReviseAccountPageState();
}

class _ReviseAccountPageState extends State<ReviseAccountPage> {
  final ReviseAccountController controller = Get.put(ReviseAccountController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Obx(() => Scaffold(
          appBar: CommonAppBar.arrowBack(context, title: '修改账号', actions: [
            GestureDetector(
              onTap: controller.reviseOnTap,
              child: Container(
                padding: EdgeInsets.only(right: 16.w),
                color: Colors.transparent,
                child: Text(
                  '修改',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.color_557BF6),
                ),
              ),
            )
          ]),
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.w),
                Text(
                  '账号',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorStyle.c333333
                  ),
                ),
                SizedBox(height: 12.w),
                Container(
                    height: 40.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: ColorStyle.c333333.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          focusNode: controller.focusEmail,
                          keyboardType: TextInputType.text,
                          controller: controller.controllerAccount,
                          style: TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            isDense: true,
                            hintText: '请输入账号',
                            hintStyle:
                            TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
                            contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                          ),
                          onChanged: (text) {
                            if (text.contains(' ')) {
                              String newText = text.replaceAll(' ', '');
                              controller.controllerAccount.text = newText;
                              controller.controllerAccount.selection =
                                  TextSelection.collapsed(offset: newText.length);
                            }controller.checkValid();
                          },
                        ))
                      ],
                    )),
                Padding(
                  padding: controller.isShowAccountTips.value
                      ? EdgeInsets.symmetric(vertical: 10.w)
                      : EdgeInsets.zero,
                  child: SizedBox(
                    height: 16.w,
                    child: Text(
                      controller.isShowAccountTips.value
                          ? '*6-15位，允许输入英文大小写字母、数字'
                          : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: controller.isShowAccountTips.value
                            ? Colors.red
                            : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )))
    );
  }

  @override
  void dispose() {
    Get.delete<ReviseAccountController>();
    super.dispose();
  }
}
