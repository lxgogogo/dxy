import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/button.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';

class RegisterContent extends StatefulWidget {
  RegisterContent({Key? key}) : super(key: key);

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  int _countdown = 60;
  bool _isCountingDown = false;
  bool _isVisible = false;
  bool _isVisibleAgain = false;

  final TextEditingController _controllerEmail = TextEditingController();
  bool isShowAccountTips = false;
  final TextEditingController _controllerCode = TextEditingController();
  bool isShowCodeTips = false;
  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  final TextEditingController _controllerAgainPw = TextEditingController();
  bool isShowAgainTips = false;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _startCountdown() {
    if (mounted) {
      setState(() {
        _isCountingDown = true;
        _countdown = 60;
      });
    }

    Timer.periodic(Duration(seconds: 1), (timer) {
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
  Widget build(BuildContext context) {
    return Padding(
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
                border: Border.all(color: const Color(0xffCCD7F0))),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '请输入邮箱地址',
                      hintStyle: AppTheme.text999999Size14,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isShowAccountTips)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 8.w),
              child: Text(
                '请输入正确的邮箱地址',
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            )
          else
            SizedBox(height: 30.w),
          Container(
            height: 50.px,

            padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.px),
                border: Border.all(color: const Color(0xffCCD7F0))),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerCode,
                    keyboardType: TextInputType.number,
                    // maxLength: 8,
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '验证码',
                      hintStyle: AppTheme.text999999Size14,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
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
          if (isShowCodeTips)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 8.w),
              child: Text(
                '验证码错误',
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            )
          else
            SizedBox(height: 30.w),
          Container(
            height: 50.px,

            padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.px),
                border: Border.all(color: const Color(0xffCCD7F0))),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerPw,
                    obscureText: !_isVisible, // 输入内容显示为密文
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '密码',
                      hintStyle: AppTheme.text999999Size14,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
                    },
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    !_isVisible ? 'assets/images/eye_close.png' : 'assets/images/eye_open.png',
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
          if (isShowPwTips)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 8.w),
              child: Text(
                '限制8～12位，必须为英文或和数字组合。密码区分大小写。不能为纯数字或字母。',
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            )
          else
            SizedBox(height: 30.w),
          Container(
            height: 50.px,

            padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.px),
                border: Border.all(color: const Color(0xffCCD7F0))),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerAgainPw,
                    obscureText: !_isVisibleAgain, // 输入内容显示为密文
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '再次输入密码',
                      hintStyle: AppTheme.text999999Size14,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
                    },
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    !_isVisibleAgain ? 'assets/images/eye_close.png' : 'assets/images/eye_open.png',
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
          if (isShowAgainTips)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 8.w),
              child: Text(
                '两次输入密码不一致。',
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            )
          else
            SizedBox(height: 30.w),
          CustomButton(
            onPressed: registerOrConfirm,
            disable: _isLoginDisable,
            height: 50.w,
            title: '注册',
          ),
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
    //注册

    //提交
    NetRequest().registerAccount(email, password, code, (data) {
      ToastUtils.showToast('注册成功');
      //成功后直接登录 通知关闭登录页面
      LoginHelper().userLogin(email, password, (data) {
        EventBusManager.eventBus.fire(EventBusAction.closeLoginPage.eventBusTypeName);
        Navigator.of(context).pop();
      });
    });
  }
}
