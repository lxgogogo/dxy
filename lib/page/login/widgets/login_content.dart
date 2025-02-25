import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/user_terms.dart';
import 'package:holdem/page/login/widgets/user_terms_uncheck.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/widget/button.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key, required this.goRegister}) : super(key: key);
  final Function goRegister;

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final TextEditingController _controllerAccount = TextEditingController();
  bool isShowAccountTips = false;
  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  bool isLogin = true;
  bool isOpen = false;

  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPwd = FocusNode();

  bool _isLoginDisable = true;

  RegExp passwordRegExp = RegExp(r'''[!"#\$%&'()*+,-./:;<=>?@\[\]^_`{|}~a-zA-Z0-9]''');

  void checkValid() {
    final account = _controllerAccount.text;
    isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final password = _controllerPw.text;
    isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty;
    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        password.isEmpty ||
        isShowPwTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerAccount.text;
    final isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips =
        !passwordRegExp.hasMatch(password) && password.isNotEmpty;
    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        password.isEmpty ||
        isShowPwTips;
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
    _focusPwd.addListener(() {
      if (!_focusPwd.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reviewTerms() {
    Get.toNamed(
      Routes.termsAndPrivacy,
      arguments: {
        'title': '用户协议',
      },
    );
  }

  void reviewPrivacy() {
    Get.toNamed(
      Routes.termsAndPrivacy,
      arguments: {
        'title': '隐私政策',
        'url': 'https://privacyagreement.dxbet.com/',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              borderRadius: BorderRadius.circular(12.w),
              // border: Border.all(
              //     color: _focusEmail.hasFocus
              //         ? Color(0xff249CFC)
              //         : Color(0xffCCD7F0))
            ),
            child: Row(
              children: <Widget>[
                // Image.asset(
                //   'assets/images/email.png',
                //   width: 14.w,
                //   height: 14.w,
                // ),
                Expanded(
                  child: TextField(
                    focusNode: _focusEmail,
                    keyboardType: TextInputType.text,
                    controller: _controllerAccount,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp('[\\s]'),
                      )
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '账号',
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
          SizedBox(
            height: 12.w,
          ),
          if (isShowAccountTips)
            Padding(
              padding: EdgeInsets.only(left: 10.w, bottom: 10.w),
              child: Text(
                isShowAccountTips ? '*请输入正确邮箱' : '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
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
                    focusNode: _focusPwd,
                    obscureText: !isOpen,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '密码',
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
                  onTap: () {
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
                  child: Image.asset(
                    isOpen
                        ? 'assets/images/eye_open.png'
                        : 'assets/images/eye_close.png',
                    width: 18.w,
                    height: 18.w,
                  ),
                )
              ],
            ),
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 10.w, top: 10.w),
                child: Text(
                  isShowPwTips ? '*密码错误' : '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.forgetPassword);
                },
                child: Text(
                  '忘记密码?',
                  style: TextStyle(fontSize: 12, color: '#557BF6'.hexColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 48.w),
          // Center(
          //   child: UserTermsUncheck(
          //     reviewTerms: reviewTerms,
          //     reviewPrivacy: reviewPrivacy,
          //   ),
          // ),
          // SizedBox(height: 12.w),
          CustomButton(
            onPressed: login,
            disable: _isLoginDisable,
            showOpacityAnimation: true,
            textColor: Colors.white,
            height: 48.w,
            title: '登录',
          ),
          SizedBox(height: 24.w),
          goRegister()
        ],
      ),
    );
  }

  Widget goRegister() {
    return Center(
      child: GestureDetector(
        onTap: () {
          widget.goRegister.call();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '没有账号？',
              style: TextStyle(fontSize: 12, color: '#333333'.hexColor),
            ),
            Text(
              '去注册',
              style: TextStyle(fontSize: 12, color: '#557BF6'.hexColor),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    var account = _controllerAccount.text;
    var password = _controllerPw.text;
    LoginHelper().userLogin(account, password, (data) {
      Get.until((route) => route.settings.name == Routes.main);
    });
  }
}
