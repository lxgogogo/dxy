import 'dart:async';

import 'package:flutter/material.dart';
import 'package:holdem/view/forum/ToastUtils.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';

class RegisterAccountPage extends StatefulWidget {
  static const PageType_RegisterAccount = 1; //注册
  static const PageType_ForgotPassword = 2; //忘记密码
  static const PageType_ModifyPassword = 3; //修改密码

  var type = -1;

  RegisterAccountPage({Key? key, required this.type}) : super(key: key);

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  int _countdown = 60;
  bool _isCountingDown = false;
  bool _isVisible = false;

  var pageType = -1;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerCode = TextEditingController();
  final TextEditingController _controllerPw = TextEditingController();
  final TextEditingController _controllerAgainPw = TextEditingController();

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 60;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isCountingDown = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageType = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppTheme.white,
        title: null,
        centerTitle: true,
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: AppTheme.white,
    );
  }

  Widget contentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(40.px, 40.px, 16.px, 0),
            child: Text(
              getPageTitle(),
              style: AppTheme.text3B5078Size23,
            )),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 35.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
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
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 10.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controllerCode,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
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
                      '$_countdown秒后可重新发送',
                      style: AppTheme.text999999Size16,
                    )
                  : GestureDetector(
                      onTap: () {
                        _startCountdown();
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
          color: Colors.white,
          margin: EdgeInsets.only(top: 10.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
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
                ),
              ),
              IconButton(
                icon: Image.asset(
                  _isVisible
                      ? 'assets/images/eye_visible.png'
                      : 'assets/images/eye_invisible.png',
                  width: 22.px,
                  height: 22.px,
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
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 10.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controllerAgainPw,
                  obscureText: !_isVisible, // 输入内容显示为密文
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText: '再次输入密码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
                ),
              ),
              IconButton(
                icon: Image.asset(
                  _isVisible
                      ? 'assets/images/eye_visible.png'
                      : 'assets/images/eye_invisible.png',
                  width: 22.px,
                  height: 22.px,
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
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        SizedBox(
          height: 30.px,
        ),
        Center(
            child: IconButton(
                icon: Image.asset(
                  'assets/images/registration_btn.png',
                  width: 295.px,
                  height: 42.5.px,
                ),
                onPressed: () {
                  registerOrConfirm();
                })),
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
    //提交
  }

  String getPageTitle() {
    if (pageType == RegisterAccountPage.PageType_RegisterAccount) {
      return '注册账号';
    } else if (pageType == RegisterAccountPage.PageType_ForgotPassword) {
      return '忘记密码';
    } else if (pageType == RegisterAccountPage.PageType_ModifyPassword) {
      return '修改密码';
    }
    return '注册账号';
  }
}
