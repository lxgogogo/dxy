import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/dialog_edit_password.dart';

import 'revise_password_controller.dart';

class RevisePasswordPage extends StatefulWidget {
  const RevisePasswordPage({Key? key}) : super(key: key);

  @override
  State<RevisePasswordPage> createState() => _RevisePasswordPageState();
}

class _RevisePasswordPageState extends State<RevisePasswordPage> {
  final RevisePasswordController controller =
      Get.put(RevisePasswordController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Obx(() => Scaffold(
            appBar: CommonAppBar.arrowBack(context, title: '修改密码', actions: [
              GestureDetector(
                onTap: () {
                  controller.reviseOnTap(context);
                },
                child: Container(
                  padding: EdgeInsets.only(right: 16.w),
                  color: Colors.transparent,
                  child: Text(
                    '完成',
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
                    '原密码',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.c333333),
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
                          Expanded(
                              child: TextField(
                            controller: controller.controllerOriginalPw,
                            // focusNode: _focusOriginalPw,
                            style: TextStyle(
                              color: AppTheme.color_333333,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            obscureText:
                                controller.originalPwdObscureText.value,
                            onChanged: (_) {
                              controller.checkValid();
                            },
                            decoration: InputDecoration(
                              isCollapsed: true,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 0.w),
                              hintText: '请输入原密码',
                              hintStyle: TextStyle(
                                color: '#3333334D'.hexColor,
                                fontSize: 12.sp,
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomObscure(
                              onTap: () {
                                controller.originalPwdObscureText.value =
                                    !controller.originalPwdObscureText.value;
                              },
                              obscureText:
                                  controller.originalPwdObscureText.value,
                            ),
                          )
                        ],
                      )),
                  Padding(
                    padding: controller.isShowOriginalPwTips.value
                        ? EdgeInsets.symmetric(vertical: 10.w)
                        : EdgeInsets.zero,
                    child: SizedBox(
                      height: 16.w,
                      child: Text(
                        controller.isShowOriginalPwTips.value
                            ? '请输入8-12位，须包含大小写字母+数字'
                            : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: controller.isShowOriginalPwTips.value
                              ? Colors.red
                              : '#95A3C4'.hexColor,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '新密码',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.c333333),
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
                          Expanded(
                              child: TextField(
                            controller: controller.controllerPw,
                            focusNode: controller.focusPw,
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            obscureText: controller.newPwdObscureText.value,
                            onChanged: (_) {
                              controller.checkValid();
                            },
                            decoration: InputDecoration(
                              isCollapsed: true,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 0.w),
                              hintText: '请输入新密码',
                              hintStyle: TextStyle(
                                color: '#3333334D'.hexColor,
                                fontSize: 12.sp,
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomObscure(
                              onTap: () {
                                controller.newPwdObscureText.value =
                                    !controller.newPwdObscureText.value;
                                setState(() {});
                              },
                              obscureText: controller.newPwdObscureText.value,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.w),
                    child: Text(
                      controller.isShowPwTips.value
                          ? controller.isContainsInvalidChars.value
                              ? '*仅允许英文字母、数字及特殊字符如@#\$%!'
                              : '*至少包含一位大小写字母+数字'
                          : '*8-12字符，至少包含大小写字母+数字',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: controller.isShowPwTips.value
                            ? Colors.red
                            : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  Text(
                    '再次输入新密码',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.c333333),
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
                          Expanded(
                              child: TextField(
                            controller: controller.controllerAgainPw,
                            focusNode: controller.focusAgainPw,
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            obscureText: controller.confirmPwdObscureText.value,
                            onChanged: (_) {
                              controller.checkValid();
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 0.w),
                              hintText: '请再次输入新密码',
                              hintStyle: TextStyle(
                                color: '#3333334D'.hexColor,
                                fontSize: 12.sp,
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomObscure(
                              onTap: () {
                                controller.confirmPwdObscureText.value =
                                    !controller.confirmPwdObscureText.value;
                                setState(() {});
                              },
                              obscureText:
                                  controller.confirmPwdObscureText.value,
                            ),
                          )
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                    child: Text(
                      controller.isShowAgainTips.value ? '*两次密码输入不一致' : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: controller.isShowAgainTips.value
                            ? Colors.red
                            : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                ],
              ),
            ))));
  }

  @override
  void dispose() {
    Get.delete<RevisePasswordController>();
    super.dispose();
  }
}
