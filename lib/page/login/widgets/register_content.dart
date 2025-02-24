import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/page/login/widgets/user_terms.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/button.dart';

import '../../../utils/app_theme.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({Key? key, required this.goLogin}) : super(key: key);
  final Function goLogin;
  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
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
        isShowAgainTips ||
        !_didAgreeTerms.value;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerEmail.text;
    final isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    final isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips =
        !passwordRegExp.hasMatch(password) && password.isNotEmpty;
    final againPw = _controllerAgainPw.text;
    final isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        code.isEmpty ||
        isShowCodeTips ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips ||
        !_didAgreeTerms.value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _didAgreeTerms = ValueNotifier<bool>(false);
    _didAgreeTerms.addListener(() {
      onChangeCheckValid();
    });
    _focusEmail.addListener(() {
      if (!_focusEmail.hasFocus) {
        checkValid();
      }
    });
    _focusCode.addListener(() {
      if (!_focusCode.hasFocus) {
        checkValid();
      }
    });
    _focusPw.addListener(() {
      if (!_focusPw.hasFocus) {
        checkValid();
      }
    });
    _focusAgainPw.addListener(() {
      if (!_focusAgainPw.hasFocus) {
        checkValid();
      }
    });
  }

  @override
  void dispose() {
    _didAgreeTerms.dispose();
    super.dispose();
  }

  ///隐私协议
  ValueNotifier<bool> get didAgreeTerms => _didAgreeTerms;
  late ValueNotifier<bool> _didAgreeTerms;

  void onTermsCheck() {
    _didAgreeTerms.value = !_didAgreeTerms.value;
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
              borderRadius: BorderRadius.circular(12.w),),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    focusNode: _focusEmail,
                    keyboardType: TextInputType.text,
                    controller: _controllerEmail,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp('[\\s]'),
                      )
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none, // 没有边框
                      hintText: '请输入邮箱',
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
          Padding(
            padding:isShowAccountTips? EdgeInsets.symmetric(vertical: 3.w):EdgeInsets.zero,
            child: Text(
              isShowAccountTips ? '*请输入正确邮箱地址' : '',
              style: TextStyle(
                fontSize: 10.sp,
                color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
              ),
            ),
          ),
          Container(
            height: 44.w,
            padding: EdgeInsets.symmetric(horizontal: 10.0.w), // 水平内边距
            decoration: BoxDecoration(
              color: '#f5f5f5'.hexColor,
              borderRadius: BorderRadius.circular(12.w),),
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
                      hintText: '请输入验证码',
                      hintStyle: TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 10.w, 0),
                    ),
                    onChanged: (_) {
                      onChangeCheckValid();
                    },
                  ),
                ),
                CountDownView(
                  type: NetRequest.SEND_CODE_TYPE_REGISTER,
                  email: _controllerEmail.text,
                ),
              ],
            ),
          ),
          Padding(
            padding: isShowCodeTips?EdgeInsets.symmetric(vertical: 3.w):EdgeInsets.zero,
            child: Text(
              isShowCodeTips ? '*验证码错误' : '',
              style: TextStyle(
                fontSize: 10.sp,
                color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
              ),
            ),
          ),
          Container(
            height: 44.w,
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            // 水平内边距
            decoration: BoxDecoration(
              color: '#f5f5f5'.hexColor,
              borderRadius: BorderRadius.circular(12.w),),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerPw,
                    focusNode: _focusPw,
                    obscureText: !_isVisible,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入密码',
                      hintStyle:  TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                      contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                    ),
                    onChanged: (_) {
                      onChangeCheckValid();
                    },
                  ),
                ),
                GestureDetector(
                  child: Image.asset(
                    _isVisible
                        ? 'assets/images/eye_open.png'
                        : 'assets/images/eye_close.png',
                    width: 18.w,
                    height: 18.w,
                  ),
                  onTap: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:EdgeInsets.symmetric(vertical: 6.w),
            child: Text(
              '*限制8-12位字符，须包含英数字，且有1个以上的英文大小写',
              style: TextStyle(
                fontSize: 10.sp,
                color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
              ),
            ),
          ),
          Container(
            height: 40.w,
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            // 水平内边距
            decoration: BoxDecoration(
              color: '#f5f5f5'.hexColor,
              borderRadius: BorderRadius.circular(12.w),),
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
                      hintText: '请再次输入密码',
                      hintStyle:  TextStyle(fontSize: 14, color: '#bfbfbf'.hexColor),
                      contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                    ),
                    onChanged: (_) {
                      onChangeCheckValid();
                    },
                  ),
                ),
                GestureDetector(
                  child: Image.asset(
                    _isVisibleAgain
                        ? 'assets/images/eye_open.png'
                        : 'assets/images/eye_close.png',
                    width: 18.w,
                    height: 18.w,
                  ),
                  onTap: () {
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
            padding:EdgeInsets.symmetric(vertical: 6.w),
            child: Text(
              '*限制8-12位字符，须包含英数字，且有1个以上的英文大小写',
              style: TextStyle(
                fontSize: 10.sp,
                color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
              ),
            ),
          ),
          SizedBox(height: 48.w),
          // UserTerms(
          //   onTermsCheck: onTermsCheck,
          //   didAgreeTerms: didAgreeTerms,
          //   reviewTerms: reviewTerms,
          //   reviewPrivacy: reviewPrivacy,
          // ),
          // SizedBox(height: 12.w),
          CustomButton(
            onPressed: registerOrConfirm,
            disable: _isLoginDisable,
            showOpacityAnimation: true,
            textColor: Colors.white,
            height: 48.w,
            title: '注册',
          ),
          SizedBox(height: 24.w),
          goLogin()
        ],
      ),
    );
  }

  Widget goLogin() {
    return Center(
      child: GestureDetector(
        onTap: () {
          widget.goLogin.call();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '已有账号？',
              style: TextStyle(fontSize: 12, color: '#333333'.hexColor),
            ),
            Text(
              '去登录',
              style: TextStyle(fontSize: 12, color: '#557BF6'.hexColor),
            ),
          ],
        ),
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
      LoginHelper().userLogin(email, password, (data) {
        Get.back();
        Get.delete<CountDownController>(
            tag: NetRequest.SEND_CODE_TYPE_REGISTER, force: true);
      });
    });
  }
}
