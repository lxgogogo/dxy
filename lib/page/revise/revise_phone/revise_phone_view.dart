import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'revise_phone_controller.dart';

class RevisePhonePage extends StatefulWidget {
  const RevisePhonePage({Key? key}) : super(key: key);

  @override
  State<RevisePhonePage> createState() => _RevisePhonePageState();
}

class _RevisePhonePageState extends State<RevisePhonePage> {
  final RevisePhoneController controller = Get.put(RevisePhoneController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Obx(() => Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '修改手机号', actions: [
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
                '手机号',
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
                      Text(
                        '+86 丨 ',
                        style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.controllerMobile,
                          focusNode: controller.focusMobile,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '请输入手机号',
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
                          onChanged: (text) {
                            if (text.contains(' ')) {
                              String newText = text.replaceAll(' ', '');
                              controller.controllerMobile.text = newText;
                              controller.controllerMobile.selection = TextSelection.collapsed(offset: newText.length);
                            }
                            controller.checkValid();
                          },
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  child: SizedBox(
                      height: 16.w,
                      child: Text(
                        controller.isShowMobileTips.value ? '*手机号格式错误' : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: controller.isShowMobileTips.value
                              ? Colors.red
                              : '#95A3C4'.hexColor,
                        ),
                      )
                  )
              ),
              Text(
                '验证码',
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
                            controller: controller.controllerCode,
                            focusNode: controller.focusCode,
                            style: TextStyle(
                              color: const Color(0xff3b5078),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
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
                        account: controller.controllerMobile.text,
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
                    controller.isShowCodeTips.value ? '*请输入6位数字验证码' : '',
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
        ),
      ))
    );
  }

  @override
  void dispose() {
    Get.delete<RevisePhoneController>();
    super.dispose();
  }
}
