import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../utils/toast_utils.dart';
import 'close_image_button.dart';

class DialogEditPassword extends StatefulWidget {
  const DialogEditPassword({super.key});

  @override
  State<DialogEditPassword> createState() => _DialogEditPasswordState();
}

class _DialogEditPasswordState extends State<DialogEditPassword> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerOriginalPw = TextEditingController();

  // bool isShowOriginalPwTips = false;
  // final FocusNode _focusOriginalPw = FocusNode();
  bool _originalPwdObscureText = true;

  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  final FocusNode _focusPw = FocusNode();
  bool _newPwdObscureText = true;

  final TextEditingController _controllerAgainPw = TextEditingController();
  bool isShowAgainTips = false;
  final FocusNode _focusAgainPw = FocusNode();
  bool _confirmPwdObscureText = true;
  RegExp containsInvalidChars=RegExp(r'^[A-Za-z0-9@#%!~]+$');
  bool isContainsInvalidChars=false;
  RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B\u003D\u003C\u003E\u003F\u0040\u005B\u005D\u005E\u005F\u0060\u007B\u007D\u007C\u007E]{8,12}$');

  @override
  void initState() {
    super.initState();
    // _focusOriginalPw.addListener(() {
    //   if (!_focusOriginalPw.hasFocus) {
    //     checkValid();
    //   }
    // });
    _focusPw.addListener(() {
      if (!_focusPw.hasFocus) {
        checkValid();
      }
    });
    _focusAgainPw.addListener(() {
      if (!_focusAgainPw.hasFocus) {
        checkValid();
      }
    });
  }

  void checkValid() {
    final originalPassword = _controllerOriginalPw.text;
    // isShowOriginalPwTips = !passwordRegExp.hasMatch(originalPassword) && originalPassword.isNotEmpty;
    final password = _controllerPw.text;
    isContainsInvalidChars = !containsInvalidChars.hasMatch(password);
    bool isValidPassword = passwordRegExp.hasMatch(password);
    isShowPwTips = password.isNotEmpty && (!isValidPassword || isContainsInvalidChars);
    final againPw = _controllerAgainPw.text;
    isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isDisable = originalPassword.isEmpty ||
        // isShowOriginalPwTips ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final originalPassword = _controllerOriginalPw.text;
    // isShowOriginalPwTips = !passwordRegExp.hasMatch(originalPassword) && originalPassword.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty;
    final againPw = _controllerAgainPw.text;
    final isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isDisable = originalPassword.isEmpty ||
        // isShowOriginalPwTips ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
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
          borderRadius: 10.5.w,
          margin: EdgeInsets.only(left: 32.w, right: 32.w),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.w),
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
                          "修改密码",
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0.w,
                      top: 0.w,
                      child: CloseImageButton(
                        width: 16.w,
                        height: 16.w,
                        color: '#333333'.hexColor.withOpacity(0.5),
                        onPressed: () {
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
                          buildTitleText('原密码'),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 30.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: '#333333'.hexColor.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerOriginalPw,
                                      // focusNode: _focusOriginalPw,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      obscureText: _originalPwdObscureText,
                                      onChanged: (_) {
                                        onChangeCheckValid();
                                      },
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(left: 12.w),
                                        hintText: '请输入原密码',
                                        hintStyle: TextStyle(
                                          color: '#3333334D'.hexColor,
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
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: CustomObscure(
                                      onTap: () {
                                        _originalPwdObscureText = !_originalPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _originalPwdObscureText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 2.w),
                      //   child: Text(
                      //     /*isShowOnalPwTips ? '请输入8-12位，须包含大小写字母+数字' : */
                      //     '',
                      //     style: TextStyle(
                      //       fontSize: 12.sp,
                      //       color: /*isShowOriginalPwTips ? Colors.red : */ '#95A3C4'.hexColor,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 12.w),
                      Row(
                        children: [
                          buildTitleText('新密码'),
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerPw,
                                      focusNode: _focusPw,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      obscureText: _newPwdObscureText,
                                      onChanged: (_) {
                                        onChangeCheckValid();
                                      },
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(left: 12.w),
                                        hintText: '请输入新密码',
                                        hintStyle: TextStyle(
                                          color: '#3333334D'.hexColor,
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
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: CustomObscure(
                                      onTap: () {
                                        _newPwdObscureText = !_newPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _newPwdObscureText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isShowPwTips)
                        Row(
                          children: [
                            buildTitleText(''),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.w),
                                  child: Text(
                                    isShowPwTips
                                        ? (isContainsInvalidChars
                                        ? '*包含了不允许的字符：仅允许英文字母、数字及特殊字符如 @#%!~'
                                        : '*至少包含一位大小写字母+数字')
                                        : '*限制8-12位字符，须包含英数字，且有1个以上的英文大小写',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                                    ),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      if (!isShowPwTips)
                        SizedBox(
                          height: 12.w,
                        ),
                      Row(
                        children: [
                          buildTitleText('再次输入'),
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerAgainPw,
                                      focusNode: _focusAgainPw,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      obscureText: _confirmPwdObscureText,
                                      onChanged: (_) {
                                        onChangeCheckValid();
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 12.w),
                                        hintText: '请再次输入新密码',
                                        hintStyle: TextStyle(
                                          color: '#3333334D'.hexColor,
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
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: CustomObscure(
                                      onTap: () {
                                        _confirmPwdObscureText = !_confirmPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _confirmPwdObscureText,
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
                          buildTitleText(''),
                          SizedBox(width: 8.w),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.w),
                            child: Text(
                              isShowAgainTips ? '*两次密码输入不一致' : '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.5.w),
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
                                  fontSize: 12.w,
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
                                  fontSize: 12.w,
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

  Widget buildTitleText(String title) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Text(
          title,
          style: TextStyle(
            color: '#333333'.hexColor,
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
          ),
        ),
        Opacity(
          opacity: 0,
          child: Text(
            '四字占位',
            style: TextStyle(
              color: '#333333'.hexColor,
              fontSize: 14.w,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _submitUpdate() {
    if (_isDisable) {
      return;
    }
    NetRequest().updatePassword(_controllerOriginalPw.text, _controllerPw.text, (data) {
      ToastUtils.showToast('修改密码成功');
      Navigator.of(context).pop();
    });
  }
}

class CustomObscure extends StatelessWidget {
  final VoidCallback? onTap;
  final bool obscureText;

  const CustomObscure({super.key, this.onTap, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(
        obscureText ? 'assets/images/eye_close.png' : 'assets/images/eye_open.png',
        width: 18.w,
      ),
    );
  }
}
