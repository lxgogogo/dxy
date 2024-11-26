import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/button.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../utils/storage.dart';

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
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login_bg.png',
            width: 375.px,
          ),
          contentView(),
          Positioned(
              top: MediaQuery.paddingOf(context).top + 9.px,
              left: 15.px,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/back_white.png',
                  height: 16.px,
                ),
                onPressed: Get.back,
              )),
        ],
      ),
    ));
  }

  Widget contentView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(20.px, 80.px, 16.px, 45.px),
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/images/logo.png',
                width: 153.px,
                height: 43.px,
              )),
          Padding(
            padding: EdgeInsets.only(top: 0, left: 30.px, right: 30.px),
            child: Text(
              '忘记密码',
              style: TextStyle(fontSize: 18.px, fontWeight: FontWeight.w500, color: Color(0xff3B5078)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 50.px,
                  margin: EdgeInsets.only(top: 35.px),
                  padding: EdgeInsets.symmetric(horizontal: 20.0.px),
                  // 水平内边距
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.px),
                      border: Border.all(color: _focusEmail.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controllerEmail,
                          focusNode: _focusEmail,
                          decoration: InputDecoration(
                            border: InputBorder.none, // 没有边框
                            hintText: '请输入邮箱地址',
                            hintStyle: AppTheme.text999999Size14,
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
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
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Text(
                    isShowAccountTips ? '请输入正确的邮箱地址，必须包含@和.，其余为英数字与_' : '请输入邮箱地址，必须包含@和.，其余为英数字与_',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isShowAccountTips ? Colors.red : '95A3C4'.hexColor,
                    ),
                  ),
                ),
                Container(
                  height: 50.px,

                  padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.px),
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
                            hintStyle: AppTheme.text999999Size14,
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
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
                                if (!LoginHelper().isValidEmail(email)) {
                                  ToastUtils.showToast('请输入正确格式邮箱');
                                  return;
                                }
                                _startCountdown(); //启动倒计时
                                NetRequest().sendCode(NetRequest.SEND_CODE_TYPE_REGISTER, email, (data) {});
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
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Text(
                    isShowCodeTips ? '请输入6位数字验证码' : '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isShowCodeTips ? Colors.red : '95A3C4'.hexColor,
                    ),
                  ),
                ),
                Container(
                  height: 50.px,
                  padding: EdgeInsets.symmetric(horizontal: 20.0.px),
                  // 水平内边距
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.px),
                      border: Border.all(color: _focusPw.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controllerPw,
                          focusNode: _focusPw,
                          obscureText: !_isVisible,
                          // 输入内容显示为密文
                          decoration: InputDecoration(
                            border: InputBorder.none, // 没有边框
                            hintText: '请设置新密码',
                            hintStyle: AppTheme.text999999Size14,
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                          ),
                          onChanged: (_) {
                            onChangeCheckValid();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Image.asset(
                          _isVisible ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
                          width: 18.px,
                          height: 18.px,
                        ),
                        onPressed: () {
                          setState(() {
                            _isVisible = !_isVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Text(
                    isShowPwTips ? '请输入8-12位，须包含大小写字母+数字' : '限制8～12位的字符，必须包含英数字，且有1个以上的英文大小写',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isShowPwTips ? Colors.red : '95A3C4'.hexColor,
                    ),
                  ),
                ),
                Container(
                  height: 50.px,
                  padding: EdgeInsets.symmetric(horizontal: 20.0.px),
                  // 水平内边距
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.px),
                      border: Border.all(color: _focusAgainPw.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
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
                            hintStyle: AppTheme.text999999Size14,
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                          ),
                          onChanged: (_) {
                            onChangeCheckValid();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Image.asset(
                          _isVisibleAgain ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
                          width: 18.px,
                          height: 18.px,
                        ),
                        onPressed: () {
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
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Text(
                    isShowAgainTips ? '两次输入的密码不一致' : '限制8～12位的字符，必须包含英数字，且有1个以上的英文大小写',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isShowAgainTips ? Colors.red : '95A3C4'.hexColor,
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
      //保存账号密码，获取本人信息接口需要
      StorageUtil().prefs!.setString('userAccount', email);
      StorageUtil().prefs!.setString('userPw', password);
      Navigator.of(context).pop();
    });
  }
}
