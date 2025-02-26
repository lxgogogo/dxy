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

  RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B\u003D\u003C\u003E\u003F\u0040\u005B\u005D\u005E\u005F\u0060\u007B\u007D\u007C\u007E]{8,12}$');

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
    isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty;
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
          borderRadius: 10.5.px,
          margin: EdgeInsets.only(left: 18.px, right: 18.px),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.px),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.px,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "修改密码",
                          style: TextStyle(
                            color: const Color(0xff3b5078),
                            fontSize: 17.px,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.px,
                      top: 10.px,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          "assets/svg/icon_close.svg",
                          width: 28.px,
                          height: 28.px,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21.5.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          buildTitleText('原密码'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _controllerOriginalPw,
                                // focusNode: _focusOriginalPw,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                obscureText: _originalPwdObscureText,
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入原密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _originalPwdObscureText = !_originalPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _originalPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        child: Text(
                          /*isShowOriginalPwTips ? '请输入8-12位，须包含大小写字母+数字' : */
                          '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: /*isShowOriginalPwTips ? Colors.red : */ '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          buildTitleText('新密码'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _controllerPw,
                                focusNode: _focusPw,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                obscureText: _newPwdObscureText,
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入新密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _newPwdObscureText = !_newPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _newPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        child: Text(
                          isShowPwTips ? '请输入8-12位，须包含大小写字母+数字' : '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          buildTitleText('再次输入'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _controllerAgainPw,
                                focusNode: _focusAgainPw,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                obscureText: _confirmPwdObscureText,
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请再次输入密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _confirmPwdObscureText = !_confirmPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _confirmPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        child: Text(
                          isShowAgainTips ? '两次密码输入不一致' : '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.5.px),
                      CustomButton(
                        onPressed: _submitUpdate,
                        disable: _isDisable,
                        height: 42.px,
                        title: '确认',
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
      children: [
        Opacity(
          opacity: 0,
          child: Text(
            '四字占位',
            style: TextStyle(
              color: const Color(0xff3b5078),
              fontSize: 15.px,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xff3b5078),
            fontSize: 15.px,
            fontWeight: FontWeight.w500,
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
        obscureText ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
        width: 18.px,
      ),
    );
  }
}
