import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/view/forum/ToastUtils.dart';

import '../../model/user.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/global.dart';
import '../../utils/size_fit.dart';
import '../../utils/storage.dart';
import '../../widget/page_web_fit.dart';

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
  final TextEditingController _controllerOldPw = TextEditingController();
  final TextEditingController _controllerCode = TextEditingController();
  final TextEditingController _controllerPw = TextEditingController();
  final TextEditingController _controllerAgainPw = TextEditingController();

  int _focusedIndex = -1;

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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return contentView();
  }

  Widget contentView() {
    return Column(
      children: [
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 35.px, left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(
                  color: _focusedIndex == 0
                      ? const Color(0xff249CFC)
                      : const Color(0xffCCD7F0))),
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
        SizedBox(height: 30.px,),
        Container(
          height: 50.px,
          margin: EdgeInsets.only( left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(
                  color: _focusedIndex == 1
                      ? const Color(0xff249CFC)
                      : const Color(0xffCCD7F0))),
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
                      style: AppTheme.text999999Size16,
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
                        NetRequest().sendCode(
                            NetRequest.SEND_CODE_TYPE_REGISTER,
                            email,
                            (data) {});
                      },
                      child: Text(
                        '发送验证码',
                        style: AppTheme.text008EFFSize16,
                      ),
                    )
            ],
          ),
        ),
        SizedBox(height: 30.px,),
        Container(
          height: 50.px,
          margin: EdgeInsets.only( left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(
                  color: _focusedIndex == 2
                      ? const Color(0xff249CFC)
                      : const Color(0xffCCD7F0))),
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
                      ? 'assets/images/eye_close.png'
                      : 'assets/images/eye_open.png',
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
        SizedBox(height: 30.px,),
        Container(
          height: 50.px,
          margin: EdgeInsets.only( left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px), // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(
                  color: _focusedIndex == 3
                      ? const Color(0xff249CFC)
                      : const Color(0xffCCD7F0))),
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
                ),
              ),
              IconButton(
                icon: Image.asset(
                  _isVisibleAgain
                      ? 'assets/images/eye_close.png'
                      : 'assets/images/eye_open.png',
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
        Center(
          child:GestureDetector(
            onTap: () {
              registerOrConfirm();
            },
            child: Container(
              width: 315.px,
              height: 48.px,
              padding: EdgeInsets.only(bottom: 7.px),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/login_btn.png'),
                      fit: BoxFit.contain)),
              child: Text(
                '注册',
                style: TextStyle(color: Colors.white, fontSize: 15.px),
              ),
            ),
          )
            // child: IconButton(
            //     icon: Image.asset(
            //       'assets/images/registration_btn.png',
            //       width: 295.px,
            //       height: 42.5.px,
            //     ),
            //     onPressed: () {
            //       registerOrConfirm();
            //     })
                ),
      ],
    );
  }

  //注册提交或者修改密码提交
  void registerOrConfirm() {
    var email = _controllerEmail.text;
    var code = _controllerCode.text;
    var password = _controllerPw.text;
    var oldPassword = _controllerOldPw.text;
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
        EventBusManager.eventBus
            .fire(EventBusAction.closeLoginPage.eventBusTypeName);
        Navigator.of(context).pop();
      });
    });
  }
}
