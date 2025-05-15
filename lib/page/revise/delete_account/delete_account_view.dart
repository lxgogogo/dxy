import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'delete_account_controller.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final DeleteAccountController controller = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
          appBar: CommonAppBar.arrowBack(context, title: '注销账号', actions: [
            GestureDetector(
              onTap: controller.reviseOnTap,
              child: Container(
                padding: EdgeInsets.only(right: 16.w),
                color: Colors.transparent,
                child: Text(
                  '注销',
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
                  '请在下方输入 "DELETE ACCOUNT"\n确认删除您的帐号',
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
                          controller: controller.controllerEmail,
                          focusNode: controller.focusEmail,
                          style: TextStyle(
                            color: ColorStyle.c333333,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
                            hintText: '请在下方输入 "DELETE ACCOUNT" ',
                            hintStyle: TextStyle(
                              color: AppTheme.color_999999,
                              fontSize: 12.sp,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                          ),
                          onChanged: (text) {
                            controller.checkValid();
                          },
                        ))
                      ],
                    )),
              ],
            ),
          )
      )
    );
  }

  @override
  void dispose() {
    Get.delete<DeleteAccountController>();
    super.dispose();
  }
}