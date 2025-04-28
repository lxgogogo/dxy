import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/services/index.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../constants.dart';
import '../utils/toast_utils.dart';
import 'close_image_button.dart';

class DialogEditMobile extends StatefulWidget {
  final String editContent; //
  const DialogEditMobile({super.key, required this.editContent});

  @override
  State<DialogEditMobile> createState() => _DialogEditMobileState();
}

class _DialogEditMobileState extends State<DialogEditMobile> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerMobile = TextEditingController();
  bool isShowMobileTips = false;
  final FocusNode _focusMobile = FocusNode();
  final TextEditingController _controllerCode = TextEditingController();
  bool isShowCodeTips = false;
  final FocusNode _focusCode = FocusNode();

  void checkValid() {
    final mobile = _controllerMobile.text;
    isShowMobileTips = !Constants.phoneRegExp.hasMatch(mobile) && mobile.isNotEmpty;
    final code = _controllerCode.text;
    isShowCodeTips = !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;

    _isDisable = mobile.isEmpty || isShowMobileTips || code.isEmpty || isShowCodeTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final mobile = _controllerMobile.text;
    final isShowMobileTips = !Constants.phoneRegExp.hasMatch(mobile) && mobile.isNotEmpty;
    final code = _controllerCode.text;
    final isShowCodeTips = !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;

    _isDisable = mobile.isEmpty || isShowMobileTips || code.isEmpty || isShowCodeTips;
    setState(() {});
  }

  String get verifyType => Constants.verifyTypePhone;

  String get verifyCodeType => Constants.verifyCodeTypeChangePhone;

  @override
  void initState() {
    // _controllerMobile.text = widget.editContent;
    super.initState();
    _focusMobile.addListener(() {
      if (!_focusMobile.hasFocus) {
        checkValid();
      }
    });
    _focusCode.addListener(() {
      if (!_focusCode.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ShadowWrapper(
          borderRadius: 16.r,
          margin: EdgeInsets.only(left: 32.w, right: 32.w),
          child: Container(
            padding: EdgeInsets.only(bottom: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.w,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "修改手机号",
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CloseImageButton(
                        color: '#333333'.hexColor.withOpacity(0.5),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21.5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            "手机号",
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              height: 30.w,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: '#333333'.hexColor.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '+86 丨 ',
                                    style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerMobile,
                                      focusNode: _focusMobile,
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
                                          color: '#3333334D'.hexColor,
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
                                          _controllerMobile.text = newText;
                                          _controllerMobile.selection = TextSelection.collapsed(offset: newText.length);
                                        }
                                        onChangeCheckValid();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Opacity(
                            opacity: 0,
                            child: Text(
                              "三个字",
                              style: TextStyle(
                                color: '#333333'.hexColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              child: Text(
                                isShowMobileTips ? '*手机号格式错误' : '',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isShowMobileTips ? Colors.red : '#95A3C4'.hexColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "验证码",
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              height: 30.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: '#333333'.hexColor.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  TextField(
                                    controller: _controllerCode,
                                    focusNode: _focusCode,
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                      hintText: '请输入验证码',
                                      hintStyle: TextStyle(
                                        color: '#3333334D'.hexColor,
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
                                      onChangeCheckValid();
                                    },
                                  ),
                                  Positioned(
                                    right: 12.w,
                                    child: CountDownView(
                                      account: _controllerMobile.text,
                                      verifyType: verifyType,
                                      verifyCodeType: verifyCodeType,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Opacity(
                            opacity: 0,
                            child: Text(
                              "三个字",
                              style: TextStyle(
                                color: '#333333'.hexColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              child: Text(
                                isShowCodeTips ? '请输入6位数字验证码' : '',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 26.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 96.w,
                              height: 33.w,
                              decoration: ShapeDecoration(
                                color: '#333333'.hexColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: '#333333'.hexColor.withOpacity(0.7),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24.w),
                          InkWell(
                            onTap: _submitUpdate,
                            child: Container(
                              width: 96.w,
                              height: 33.w,
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(1.00, 0.00),
                                  end: Alignment(-1, 0),
                                  colors: [
                                    Color(0xFF84BCF9),
                                    Color(0xFF557BF6),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '确定修改',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (_isDisable) return;
    String phone = _controllerMobile.text;
    String code = _controllerCode.text;
    final res = await UserService.of.updatePhone(
      phone: phone,
      code: code,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('修改成功');
      UserStore.of.getUserInfo();
      Get.back();
      Get.delete<CountDownController>(tag: '$verifyType$verifyCodeType', force: true);
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
