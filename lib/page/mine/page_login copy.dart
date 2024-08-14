import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/mine/page_register_account.dart';
import 'package:holdem/view/forum/ToastUtils.dart';

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
  var actionEventBus;

  final FocusNode _focusNodeAccount = FocusNode();
  final FocusNode _focusNodePwd = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //接受注册成功的通知，主动关闭当前页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() ==
          EventBusAction.closeLoginPage.eventBusTypeName) {
        Navigator.of(context).pop();
      }
    });
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus) {
    //     FocusScope.of(context).requestFocus(_focusNode);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return  WebFitPage(child: Scaffold(
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
      backgroundColor: Color(0xfff5f5f5),
    ));
  }

  Widget contentView() {
    return ListView(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(40.px, 40.px, 16.px, 0),
            child: Text(
              "欢迎登录",
              style: AppTheme.text3B5078Size23,
            )),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 35.px),
          padding: EdgeInsets.symmetric(horizontal: 40.0.px), // 水平内边距
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/images/email.png',
                width: 14.px,
                height: 14.px,
              ),
              Expanded(
                child: Listener(
                    onPointerDown: (e) =>
                        FocusScope.of(context).requestFocus(_focusNodeAccount),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      autocorrect: false, //去除输入后自动选中更正功能
                      controller: _controllerAccount,
                      decoration: InputDecoration(
                        border: InputBorder.none, // 没有边框
                        hintText: '请输入邮箱地址',
                        hintStyle: AppTheme.text999999Size16,
                        contentPadding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
                      ),
                    )),
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
              Image.asset(
                'assets/images/password.png',
                width: 14.px,
                height: 14.px,
              ),
              Expanded(
                child: Listener(
                    onPointerDown: (e) =>
                        FocusScope.of(context).requestFocus(_focusNodePwd),
                    child: TextField(
                      controller: _controllerPw,
                      // focusNode: _focusNode,
                      obscureText: true, // 输入内容显示为密文
                      decoration: InputDecoration(
                        border: InputBorder.none, // 没有边框
                        hintText: '请输入密码',
                        hintStyle: AppTheme.text999999Size16,
                        contentPadding: EdgeInsets.fromLTRB(10.px, 0, 10.px, 0),
                      ),
                    )),
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
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
                icon: Image.asset(
                  'assets/images/login_btn.png',
                  width: 295.px,
                  height: 42.5.px,
                ),
                onPressed: () {
                    login();
                })),
        Container(
            margin: EdgeInsets.fromLTRB(40.px, 10.px, 40.px, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(RegisterAccountPage(type: RegisterAccountPage.PageType_ForgotPassword,));
                  },
                  child: Text(
                    '忘记密码',
                    style: AppTheme.text3B5078Size14,
                  ),
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    Get.to(RegisterAccountPage(type: RegisterAccountPage.PageType_RegisterAccount,));
                  },
                  child: Text(
                    '注册账号',
                    style: AppTheme.text3B5078Size14,
                  ),
                )
              ],
            ))
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
    LoginHelper().userLogin(account, password,(data){
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _focusNodeAccount.dispose();
    _focusNodePwd.dispose();
    super.dispose();
  }
}
