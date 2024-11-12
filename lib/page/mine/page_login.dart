import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/mine/page_register_account.dart';
import 'package:holdem/page/mine/register_content.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/close_image_button.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';
import '../../widget/page_web_fit.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerAccount = TextEditingController();
  final TextEditingController _controllerPw = TextEditingController();
  bool isLogin = true;
  bool isOpen = false;
  var actionEventBus;

  final FocusNode _focusNodeAccount = FocusNode();
  final FocusNode _focusNodePwd = FocusNode();

  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPwd = FocusNode();

  int _focusedIndex = -1;

  bool _isLoginDisable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //接受注册成功的通知，主动关闭当前页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.closeLoginPage.eventBusTypeName) {
        Navigator.of(context).pop();
      }
    });
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus) {
    //     FocusScope.of(context).requestFocus(_focusNode);
    //   }
    // });

    _focusEmail.addListener(_handleFocusChange);
    _focusPwd.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      if (_focusEmail.hasFocus) {
        _focusedIndex = 0;
      } else if (_focusPwd.hasFocus) {
        _focusedIndex = 1;
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
                right: 15.px,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CloseImageButton(onPressed: () {
                    Navigator.of(context).pop();
                  }),
                )),
          ],
        ),
      ),
    );
  }

  loginContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 50.px,
          margin: EdgeInsets.only(top: 35.px, left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px),
          // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(color: _focusedIndex == 0 ? Color(0xff249CFC) : Color(0xffCCD7F0))),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/images/email.png',
                width: 14.px,
                height: 14.px,
              ),
              Expanded(
                child: Listener(
                    onPointerDown: (e) => FocusScope.of(context).requestFocus(_focusNodeAccount),
                    child: TextField(
                      focusNode: _focusEmail,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      //去除输入后自动选中更正功能
                      controller: _controllerAccount,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp('[\\s]'),
                        )
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none, // 没有边框
                        hintText: '请输入邮箱地址',
                        hintStyle: AppTheme.text999999Size16,
                        contentPadding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
                      ),
                      onChanged: (_) {
                        checkValid();
                      },
                    )),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30.px,
        ),
        Container(
          height: 50.px,
          margin: EdgeInsets.only(left: 30.px, right: 30.px),
          padding: EdgeInsets.symmetric(horizontal: 20.0.px),
          // 水平内边距
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.px),
              border: Border.all(color: _focusedIndex == 1 ? Color(0xff249CFC) : Color(0xffCCD7F0))),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/images/password.png',
                width: 14.px,
                height: 14.px,
              ),
              Expanded(
                child: Listener(
                    onPointerDown: (e) => FocusScope.of(context).requestFocus(_focusNodePwd),
                    child: TextField(
                      controller: _controllerPw,
                      focusNode: _focusPwd,
                      obscureText: !isOpen,
                      // 输入内容显示为密文
                      decoration: InputDecoration(
                        border: InputBorder.none, // 没有边框
                        hintText: '请输入密码',
                        hintStyle: AppTheme.text999999Size16,
                        contentPadding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
                      ),
                      onChanged: (_) {
                        checkValid();
                      },
                    )),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
                child: Image.asset(
                  isOpen ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
                  width: 18.px,
                  height: 18.px,
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
        SizedBox(
          height: 30.px,
        ),
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.to(const RegisterAccountPage(
                  type: forgotPassword,
                ));
              },
              child: const Text(
                '忘记密码?',
                style: AppTheme.text3B5078Size14,
              ),
            ),
            SizedBox(
              width: 30.px,
            )
          ],
        ),
        SizedBox(
          height: 60.px,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.5.px),
          child: CustomButton(
            onPressed: login,
            disable: _isLoginDisable,
            height: 45.px,
            title: '登录',
          ),
        ),
      ],
    );
  }

  registerContent() {
    return RegisterContent();
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
        Row(
          children: [
            SizedBox(
              width: 50.px,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isLogin = true;
                });
              },
              child: Column(
                children: [
                  Text(
                    '登录',
                    style: TextStyle(
                        fontSize: 18.px,
                        fontWeight: isLogin ? FontWeight.bold : FontWeight.normal,
                        color: isLogin ? Color(0xff249CFC) : Color(0xff3B5078)),
                  ),
                  Container(
                    width: 21.px,
                    height: 3.px,
                    margin: EdgeInsets.only(top: 10.px),
                    decoration: BoxDecoration(
                        color: isLogin ? Color(0xff249CFC) : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(1.5.px))),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 25.px,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isLogin = false;
                });
              },
              child: Column(
                children: [
                  Text(
                    '注册',
                    style: TextStyle(
                        fontSize: 18.px,
                        fontWeight: !isLogin ? FontWeight.bold : FontWeight.normal,
                        color: !isLogin ? Color(0xff249CFC) : Color(0xff3B5078)),
                  ),
                  Container(
                    width: 21.px,
                    height: 3.px,
                    margin: EdgeInsets.only(top: 10.px),
                    decoration: BoxDecoration(
                        color: !isLogin ? Color(0xff249CFC) : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(1.5.px))),
                  )
                ],
              ),
            ),
          ],
        ),
        if (isLogin) loginContent(),
        if (!isLogin) registerContent()
      ],
    );
  }

  void login() {
    // if (_focusNode.hasFocus) {
    //   FocusScope.of(context).unfocus();
    // }
    var account = _controllerAccount.text;
    var password = _controllerPw.text;
    if (account.isEmpty) {
      ToastUtils.showToast('邮箱不能为空');
      return;
    }
    if (password.isEmpty) {
      ToastUtils.showToast('密码不能为空');
      return;
    }
    //登录
    LoginHelper().userLogin(account, password, (data) {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _focusNodeAccount.dispose();
    _focusNodePwd.dispose();
    _focusEmail.dispose();
    _focusPwd.dispose();
    super.dispose();
  }

  void checkValid() {
    final account = _controllerAccount.text;
    final isEmail = GetUtils.isEmail(account);
    final password = _controllerPw.text;
    _isLoginDisable = account.isEmpty || password.isEmpty || !isEmail;
    setState(() {});
  }
}
