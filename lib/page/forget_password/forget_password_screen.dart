import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/button.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';

part 'forget_password_controller.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  int _countdown = 60;
  bool _isCountingDown = false;
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
  RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,12}$');

  void checkValid() {
    final account = _controllerEmail.text;
    isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty;
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
    final isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty;
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

  void _startCountdown() {
    ToastUtils.showToast('已发送');
    if (mounted) {
      setState(() {
        _isCountingDown = true;
        _countdown = 60;
      });
    }

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _isCountingDown = false;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _focusEmail.addListener(() {
      if(!_focusEmail.hasFocus) {
        checkValid();
      }
    });
    _focusCode.addListener(() {
      if(!_focusCode.hasFocus) {
        checkValid();
      }
    });
    _focusPw.addListener(() {
      if(!_focusPw.hasFocus) {
        checkValid();
      }
    });
    _focusAgainPw.addListener(() {
      if(!_focusAgainPw.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
          extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Image.asset('assets/images/login_bg.png'),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 30.w, top: 103.w, bottom: 44.5.w),
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 38.w,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.w),
                  child: Column(
                    children: [
                      Text(
                        '忘记密码',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: '#3B5078'.hexColor,
                        ),
                      ),
                      Container(
                        width: 21.w,
                        height: 2.5.w,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 30.w,
                      ),
                      Container(
                        height: 50.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        // 水平内边距
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(25.w),
                            border: Border.all(color: _focusEmail.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/email.png',
                              width: 14.w,
                              height: 14.w,
                            ),
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
                                  hintText: '请输入邮箱地址',
                                  hintStyle: AppTheme.text999999Size16,
                                  contentPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
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
                        padding: EdgeInsets.symmetric(vertical: 8.w).copyWith(left: 20.w),
                        child: Text(
                          isShowAccountTips ? '请输入正确邮箱地址' : '范例：dxy@example.com',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      Container(
                        height: 50.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w), // 水平内边距
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(25.w),
                            border: Border.all(color: _focusCode.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
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
                                  hintText: '验证码',
                                  hintStyle: AppTheme.text999999Size16,
                                  contentPadding: EdgeInsets.fromLTRB(0, 0, 10.w, 0),
                                ),
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                              ),
                            ),
                            _isCountingDown
                                ? Text(
                              '${_countdown}s',
                              style: AppTheme.text008EFFSize16,
                            )
                                : GestureDetector(
                              onTap: () {
                                var email = _controllerEmail.text;
                                if (email.isEmpty) {
                                  ToastUtils.showToast('邮箱不能为空');
                                  return;
                                }
                                if (!GetUtils.isEmail(email)) {
                                  ToastUtils.showToast('请输入正确格式邮箱');
                                  return;
                                }
                                _startCountdown();
                                NetRequest().sendCode(NetRequest.SEND_CODE_TYPE_RESET_PW, email, (data) {});
                              },
                              child: Text(
                                '发送验证码',
                                style: AppTheme.text008EFFSize16,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.w).copyWith(left: 20.w),
                        child: Text(
                          isShowCodeTips ? '请输入6位数字验证码' : '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      Container(
                        height: 50.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        // 水平内边距
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(25.w),
                            border: Border.all(color: _focusPw.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/password.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerPw,
                                focusNode: _focusPw,
                                obscureText: !_isVisible,
                                // 输入内容显示为密文
                                decoration: InputDecoration(
                                  border: InputBorder.none, // 没有边框
                                  hintText: '请设置新密码',
                                  hintStyle: AppTheme.text999999Size16,
                                  contentPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                                ),
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                              ),
                            ),
                            GestureDetector(
                              child: Image.asset(
                                _isVisible ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
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
                        padding: EdgeInsets.symmetric(vertical: 8.w).copyWith(left: 20.w),
                        child: Text(
                          isShowPwTips ? '请输入8-12位，须包含大小写字母+数字' : '8-12位，须包含大小写字母+数字',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      Container(
                        height: 50.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        // 水平内边距
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(25.w),
                            border: Border.all(color: _focusAgainPw.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/password.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerAgainPw,
                                focusNode: _focusAgainPw,
                                obscureText: !_isVisibleAgain,
                                // 输入内容显示为密文
                                decoration: InputDecoration(
                                  border: InputBorder.none, // 没有边框
                                  hintText: '再次输入新密码',
                                  hintStyle: AppTheme.text999999Size16,
                                  contentPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                                ),
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                              ),
                            ),
                            GestureDetector(
                              child: Image.asset(
                                _isVisibleAgain ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
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
                        padding: EdgeInsets.symmetric(vertical: 8.w).copyWith(left: 20.w),
                        child: Text(
                          isShowAgainTips ? '两次输入的密码不一致' : '8-12位，须包含大小写字母+数字',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.w),
                      CustomButton(
                        onPressed: registerOrConfirm,
                        disable: _isLoginDisable,
                        height: 50.w,
                        title: '确定',
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
              top: MediaQuery.paddingOf(context).top + 9.w,
              left: 15.w,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/back_white.png',
                  height: 16.w,
                ),
                onPressed: Get.back,
              )),
        ],
      ),
    ));
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
    });
  }
}
