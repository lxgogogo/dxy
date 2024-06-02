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
    pageType = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return WebFitPage(
        child: Scaffold(
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
    ));
  }

  Widget contentView() {
    return ListView(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(40.px, 40.px, 16.px, 0),
            child: Text(
              getPageTitle(),
              style: AppTheme.text3B5078Size23,
            )),
        Visibility(
          child: Container(
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
          visible: pageType == RegisterAccountPage.PageType_ModifyPassword
              ? false
              : true,
        ),
        Visibility(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 35.px),
            padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
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
          visible: pageType == RegisterAccountPage.PageType_ModifyPassword
              ? true
              : false,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
          height: 0.5,
          color: AppTheme.color_F3F3F3,
        ),
        Visibility(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 3.px),
              padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
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
                                pageType ==
                                        RegisterAccountPage
                                            .PageType_RegisterAccount
                                    ? NetRequest.SEND_CODE_TYPE_REGISTER
                                    : NetRequest.SEND_CODE_TYPE_RESET_PW,
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
            visible: pageType == RegisterAccountPage.PageType_ModifyPassword
                ? false
                : true),
        Visibility(
          child: Container(
            margin: EdgeInsets.fromLTRB(40.px, 0, 40.px, 0),
            height: 0.5,
            color: AppTheme.color_F3F3F3,
          ),
          visible: pageType == RegisterAccountPage.PageType_ModifyPassword
              ? false
              : true,
        ),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 3.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controllerPw,
                  obscureText: !_isVisible, // 输入内容显示为密文
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText:
                        pageType == RegisterAccountPage.PageType_RegisterAccount
                            ? '密码'
                            : '请设置新密码',
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
          margin: EdgeInsets.only(top: 3.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controllerAgainPw,
                  obscureText: !_isVisibleAgain, // 输入内容显示为密文
                  decoration: InputDecoration(
                    border: InputBorder.none, // 没有边框
                    hintText:
                        pageType == RegisterAccountPage.PageType_RegisterAccount
                            ? '再次输入密码'
                            : '再次输入新密码',
                    hintStyle: AppTheme.text999999Size14,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 10.px, 0),
                  ),
                ),
              ),
              IconButton(
                icon: Image.asset(
                  _isVisibleAgain
                      ? 'assets/images/eye_visible.png'
                      : 'assets/images/eye_invisible.png',
                  width: 22.px,
                  height: 22.px,
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
            child: IconButton(
                icon: Image.asset(
                  pageType == RegisterAccountPage.PageType_RegisterAccount
                      ? 'assets/images/registration_btn.png'
                      : 'assets/images/confirm_btn.png',
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
    var oldPassword = _controllerOldPw.text;
    var againPassword = _controllerAgainPw.text;
    if (pageType == RegisterAccountPage.PageType_ModifyPassword) {
      if (oldPassword.isEmpty) {
        ToastUtils.showToast('原密码不能为空');
        return;
      }
    } else {
      if (email.isEmpty) {
        ToastUtils.showToast('邮箱不能为空');
        return;
      }
      if (code.isEmpty) {
        ToastUtils.showToast('验证码不能为空');
        return;
      }
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
    if (pageType == RegisterAccountPage.PageType_RegisterAccount) {
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
    } else if (pageType == RegisterAccountPage.PageType_ModifyPassword) {
      // 修改密码
      NetRequest().updatePassword(oldPassword, password, (data) {
        ToastUtils.showToast('修改密码成功');
        //保存账号密码，获取本人信息接口需要
        StorageUtil().prefs!.setString('userAccount', email);
        StorageUtil().prefs!.setString('userPw', password);
        Navigator.of(context).pop();
      });
    } else if (pageType == RegisterAccountPage.PageType_ForgotPassword) {
      //忘记密码
      NetRequest().registerAccount(email, password, code, (data) {
        ToastUtils.showToast('重置密码成功');
        //保存账号密码，获取本人信息接口需要
        StorageUtil().prefs!.setString('userAccount', email);
        StorageUtil().prefs!.setString('userPw', password);
        Navigator.of(context).pop();
      });
    }
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
