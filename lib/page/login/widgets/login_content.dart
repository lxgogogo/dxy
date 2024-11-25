import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/mine/page_forget_password.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/widget/button.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key}) : super(key: key);

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

  RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,12}$');

  void checkValid() {
    final account = _controllerAccount.text;
    isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty && !_focusEmail.hasFocus;
    final password = _controllerPw.text;
    isShowPwTips = !passwordRegExp.hasMatch(password) && password.isNotEmpty && !_focusPwd.hasFocus;
    _isLoginDisable = account.isEmpty || isShowAccountTips || password.isEmpty || isShowPwTips;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focusEmail.addListener(checkValid);
    _focusPwd.addListener(checkValid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      contentPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: Text(
              isShowAccountTips ? '请输入邮箱地址，必须包含@和.，其余为英数字与_' : '请输入正确的邮箱地址，必须包含@和.，其余为英数字与_',
              style: TextStyle(
                fontSize: 12.sp,
                color: isShowAccountTips ? Colors.red : '95A3C4'.hexColor,
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
                border: Border.all(color: _focusPwd.hasFocus ? Color(0xff249CFC) : Color(0xffCCD7F0))),
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
                    focusNode: _focusPwd,
                    obscureText: !isOpen,
                    // 输入内容显示为密文
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '请输入密码',
                      hintStyle: AppTheme.text999999Size16,
                      contentPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    ),
                    onChanged: (_) {
                      checkValid();
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
                    isOpen ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
                    width: 18.w,
                    height: 18.w,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: Text(
              isShowPwTips ? '限制8～12位的字符，必须包含英数字，且有1个以上的英文大小写' : '请输入8-12位，须包含大小写字母+数字',
              style: TextStyle(
                fontSize: 12.sp,
                color: isShowPwTips ? Colors.red : '95A3C4'.hexColor,
              ),
            ),
          ),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.to(const ForgetPasswordPage());
                },
                child: const Text(
                  '忘记密码?',
                  style: AppTheme.text3B5078Size14,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60.w,
          ),
          CustomButton(
            onPressed: login,
            disable: _isLoginDisable,
            height: 50.w,
            title: '登录',
          ),
        ],
      ),
    );
  }

  void login() {
    var account = _controllerAccount.text;
    var password = _controllerPw.text;
    LoginHelper().userLogin(account, password, (data) {
      Navigator.of(context).pop();
    });
  }

}
