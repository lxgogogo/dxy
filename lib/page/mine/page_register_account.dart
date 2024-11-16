import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/button.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../utils/storage.dart';

class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({Key? key}) : super(key: key);

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  int _countdown = 60;
  bool _isCountingDown = false;
  bool _isVisible = false;
  bool _isVisibleAgain = false;

  var pageType = -1;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerOldPw = TextEditingController();
  final TextEditingController _controllerCode = TextEditingController();
  final TextEditingController _controllerPw = TextEditingController();
  final TextEditingController _controllerAgainPw = TextEditingController();

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
    return ListView(
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
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 35.px, left: 30.px, right: 30.px),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 30.px, left: 30.px, right: 30.px),
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
                  controller: _controllerOldPw,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText: '请输入原密码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 30.px, left: 30.px, right: 30.px),
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
                  controller: _controllerCode,
                  keyboardType: TextInputType.number,
                  // maxLength: 8,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText: '验证码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
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
        Container(
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 30.px, left: 30.px, right: 30.px),
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
                  controller: _controllerPw,
                  obscureText: !_isVisible, // 输入内容显示为密文
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText: '请设置新密码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
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
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 30.px, left: 30.px, right: 30.px),
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
                  controller: _controllerAgainPw,
                  obscureText: !_isVisibleAgain, // 输入内容显示为密文
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText: '再次输入新密码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
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
        Container(
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        SizedBox(
          height: 30.px,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.px),
          child: CustomButton(
            onPressed: registerOrConfirm,
            height: 45.px,
            title: '确定',
          ),
        ),
      ],
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
