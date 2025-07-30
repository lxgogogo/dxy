import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'revise_email_controller.dart';

class ReviseEmailPage extends StatefulWidget {
  const ReviseEmailPage({Key? key}) : super(key: key);

  @override
  State<ReviseEmailPage> createState() => _ReviseEmailPageState();
}

class _ReviseEmailPageState extends State<ReviseEmailPage> {
  final ReviseEmailController controller = Get.put(ReviseEmailController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Obx(() => Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '修改邮箱', actions: [
          GestureDetector(
            onTap: controller.reviseOnTap,
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
                '邮箱',
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
                        controller: controller.controllerEmail,
                        style: TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          isDense: true,
                          hintText: '请输入邮箱地址',
                          hintStyle:
                          TextStyle(fontSize: 12.sp, color: AppTheme.color_999999),
                          contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                        ),
                        onChanged: (text) {
                          if (text.contains(' ')) {
                            String newText = text.replaceAll(' ', '');
                            controller.controllerEmail.text = newText;
                            controller.controllerEmail.selection =
                                TextSelection.collapsed(offset: newText.length);
                          }
                          controller.checkValid();
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
                        ? '*请输入正确邮箱地址'
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
              Text(
                '验证码',
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
                        controller: controller.controllerCode,
                        focusNode: controller.focusCode,
                        style: TextStyle(
                          color: const Color(0xff3b5078),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                          hintText: '请输入验证码',
                          hintStyle: TextStyle(
                            color: AppTheme.color_999999,
                            fontSize: 12.sp,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        onChanged: (_) {
                          controller.checkValid();
                        },
                      )),
                      CountDownView(
                        account: controller.controllerEmail.text,
                        verifyType: controller.verifyType,
                        verifyCodeType: controller.verifyCodeType,
                      ),

                    ],
                  )),
              Padding(
                padding: controller.isShowCodeTips.value
                    ? EdgeInsets.symmetric(vertical: 10.w)
                    : EdgeInsets.zero,
                child: SizedBox(
                  height: 16.w,
                  child: Text(
                    controller.isShowCodeTips.value
                        ? '*请输入6位数字验证码'
                        : '',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: controller.isShowCodeTips.value
                          ? Colors.red
                          : '#95A3C4'.hexColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ))
    );
  }

  @override
  void dispose() {
    Get.delete<ReviseEmailController>();
    super.dispose();
  }
}