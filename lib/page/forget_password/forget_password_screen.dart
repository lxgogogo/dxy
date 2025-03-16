import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/button.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../widget/close_image_button.dart';

part 'forget_password_controller.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool _isVisible = false;
  bool _isVisibleAgain = false;

  final TextEditingController _controllerEmail = TextEditingController();
  bool isShowAccountTips = false;
  final FocusNode _focusEmail = FocusNode();
  final TextEditingController _controllerCode = TextEditingController();
  bool isShowCodeTips = false;
  final FocusNode _focusCode = FocusNode();
  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  final FocusNode _focusPw = FocusNode();
  final TextEditingController _controllerAgainPw = TextEditingController();
  bool isShowAgainTips = false;
  final FocusNode _focusAgainPw = FocusNode();

  bool _isLoginDisable = true;
  RegExp codeRegExp = RegExp(r'^\d{6}$');
  RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B\u003D\u003C\u003E\u003F\u0040\u005B\u005D\u005E\u005F\u0060\u007B\u007D\u007C\u007E]{8,12}$');
  RegExp containsInvalidChars=RegExp(r'^[A-Za-z0-9@#%!~]+$');
  bool isContainsInvalidChars=false;
  void checkValid() {
    final account = _controllerEmail.text;
    isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    isContainsInvalidChars = !containsInvalidChars.hasMatch(password);
    bool isValidPassword = passwordRegExp.hasMatch(password);
    isShowPwTips = password.isNotEmpty && (!isValidPassword || isContainsInvalidChars);
    final againPw = _controllerAgainPw.text;
    isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        code.isEmpty ||
        isShowCodeTips ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerEmail.text;
    final isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    final isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips =
        !passwordRegExp.hasMatch(password) && password.isNotEmpty;
    final againPw = _controllerAgainPw.text;
    final isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        code.isEmpty ||
        isShowCodeTips ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focusEmail.addListener(() {
      if (!_focusEmail.hasFocus) {
        checkValid();
      }
    });
    _focusCode.addListener(() {
      if (!_focusCode.hasFocus) {
        checkValid();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/login_bg.png'),
                Positioned(
                  child: SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.w),
                      width: context.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 23.w,
                          ),
                          CloseImageButton(
                            width: 16.w,
                            height: 16.w,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 24.w),
              child: Column(
                children: [
                  Text(
                    '忘记密码',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: '#333333'.hexColor,
                    ),
                  ),
                  Container(
                    width: 21.w,
                    height: 4.w,
                    margin: EdgeInsets.only(top: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(1.5.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 30.w,
                    ),
                    Container(
                      height: 44.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                      // 水平内边距
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.w),),
                      child: Row(
                        children: <Widget>[

                          Expanded(
                            child: TextField(
                              focusNode: _focusEmail,
                              keyboardType: TextInputType.text,
                              controller: _controllerEmail,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp('[\\s]'),
                                )
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none, // 没有边框
                                hintText: '请输入邮箱',
                                hintStyle:
                                TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                                contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                              ),
                              onChanged: (_) {
                                onChangeCheckValid();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: isShowAccountTips
                          ? EdgeInsets.symmetric(vertical: 3.w)
                          : EdgeInsets.zero,
                      child: Text(
                        isShowAccountTips ? '*请输入正确邮箱地址' : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 44.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                      // 水平内边距
                      // 水平内边距
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _controllerCode,
                              focusNode: _focusCode,
                              keyboardType: TextInputType.number,
                              // maxLength: 8,
                              decoration: InputDecoration(
                                border: InputBorder.none, // 没有边框
                                hintText: '请输入验证码',
                                hintStyle:
                                TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 0, 10.w, 0),
                              ),
                              onChanged: (_) {
                                onChangeCheckValid();
                              },
                            ),
                          ),
                          CountDownView(
                            type: NetRequest.SEND_CODE_TYPE_RESET_PW,
                            email: _controllerEmail.text,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: isShowCodeTips
                          ? EdgeInsets.symmetric(vertical: 3.w)
                          : EdgeInsets.zero,
                      child: Text(
                        isShowCodeTips ? '*验证码错误' : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 44.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                      // 水平内边距
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _controllerPw,
                              focusNode: _focusPw,
                              obscureText: !_isVisible,
                              // 输入内容显示为密文
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请输入密码',
                                hintStyle:
                                TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                                contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                              ),
                              onChanged: (_) {
                                onChangeCheckValid();
                              },
                            ),
                          ),
                          GestureDetector(
                            child: Image.asset(
                              _isVisible
                                  ? 'assets/images/eye_open.png'
                                  : 'assets/images/eye_close.png',
                              width: 18.w,
                              height: 18.w,
                            ),
                            onTap: () {
                              setState(() {
                                _isVisible = !_isVisible;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.w),
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
                    Container(
                      height: 40.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                      // 水平内边距
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _controllerAgainPw,
                              focusNode: _focusAgainPw,
                              obscureText: !_isVisibleAgain,
                              // 输入内容显示为密文
                              decoration: InputDecoration(
                                border: InputBorder.none, // 没有边框
                                hintText: '再次输入新密码',
                                hintStyle:
                                TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                                contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                              ),
                              onChanged: (_) {
                                onChangeCheckValid();
                              },
                            ),
                          ),
                          GestureDetector(
                            child: Image.asset(
                              _isVisibleAgain
                                  ? 'assets/images/eye_open.png'
                                  : 'assets/images/eye_close.png',
                              width: 18.w,
                              height: 18.w,
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _isVisibleAgain = !_isVisibleAgain;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.w),
                      child: Text(
                        isShowAgainTips ? '两次输入的密码不一致' : '*限制8-12位字符，须包含英数字，且有1个以上的英文大小写',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isShowAgainTips
                              ? Colors.red
                              : '#95A3C4'.hexColor,
                        ),
                      )
                    ),
                    SizedBox(height: 48.w),
                    CustomButton(
                      onPressed: registerOrConfirm,
                      disable: _isLoginDisable,
                      textColor: Colors.white,
                      height: 48.w,
                      title: '找回密码',
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //注册提交或者修改密码提交
  void registerOrConfirm() {
    var email = _controllerEmail.text;
    var code = _controllerCode.text;
    var password = _controllerPw.text;
    var againPassword = _controllerAgainPw.text;
    if (email.isEmpty) {
      ToastUtils.showToast('邮箱不能为空');
      return;
    }
    if (code.isEmpty) {
      ToastUtils.showToast('验证码不能为空');
      return;
    }

    if (password.isEmpty) {
      ToastUtils.showToast('密码不能为空');
      return;
    }
    if (againPassword.isEmpty) {
      ToastUtils.showToast('请输入确认密码');
      return;
    }
    if (password != againPassword) {
      ToastUtils.showToast('两次输入的密码不一致');
      return;
    }
    //忘记密码
    NetRequest().resetPassword(email, password, code, (data) {
      ToastUtils.showToast('重置密码成功');
      Get.back();
      Get.delete<CountDownController>(
          tag: NetRequest.SEND_CODE_TYPE_RESET_PW, force: true);
    });
  }
}
