import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/page/login/widgets/user_terms.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/button.dart';

import '../../../constants.dart';
import 'type_selector.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({Key? key, required this.goLogin}) : super(key: key);
  final Function goLogin;

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  final List<String> typeList = ['邮箱注册', '账号注册', '手机注册'];
  int typeIndex = 0;

  String get type => typeList[typeIndex];

  bool get isMobile => typeIndex == 2;

  bool _isVisible = false;
  bool _isVisibleAgain = false;

  final TextEditingController _controllerEmail = TextEditingController();
  bool isShowAccountTips = false;

  String get accountTips {
    switch (typeIndex) {
      case 0: // 邮箱注册
        return '*请输入正确邮箱地址';
      case 1: // 账号注册
        return '*6~15位英数字，大小写不同';
      case 2: // 手机注册
        return '*手机号格式错误';
      default:
        return '';
    }
  }

  String get accountHint {
    switch (typeIndex) {
      case 0: // 邮箱注册
        return '请输入邮箱';
      case 1: // 账号注册
        return '请输入账号';
      case 2: // 手机注册
        return '请输入手机号';
      default:
        return '';
    }
  }

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
  bool isContainsInvalidChars = false;

  ///隐私协议
  ValueNotifier<bool> get didAgreeTerms => _didAgreeTerms;
  late ValueNotifier<bool> _didAgreeTerms;

  void checkValid() {
    final account = _controllerEmail.text;
    switch (typeIndex) {
      case 0: // 邮箱注册
        isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case 1: // 账号注册
        isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case 2: // 手机注册
        isShowAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }
    final code = _controllerCode.text;
    isShowCodeTips = typeIndex != 1 && !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    isContainsInvalidChars = !Constants.containsInvalidChars.hasMatch(password);
    bool isValidPassword = Constants.passwordRegExp.hasMatch(password);
    if (password.isNotEmpty) {
      if (isContainsInvalidChars) {
        isShowPwTips = true; // 包含非法字符
      } else if (!isValidPassword) {
        isShowPwTips = true; // 不满足复杂度要求
      } else {
        isShowPwTips = false; // 所有条件均满足
      }
    } else {
      isShowPwTips = false; // 密码为空时不显示提示
    }
    final againPw = _controllerAgainPw.text;
    isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isLoginDisable = account.isEmpty ||
        isShowAccountTips ||
        (typeIndex != 1 && (code.isEmpty || isShowCodeTips)) ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips ||
        !_didAgreeTerms.value;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerEmail.text;
    bool showAccountTips = false;
    switch (typeIndex) {
      case 0: // 邮箱注册
        showAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case 1: // 账号注册
        showAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case 2: // 手机注册
        showAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }
    final code = _controllerCode.text;
    final isShowCodeTips = typeIndex != 1 && !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips = !Constants.passwordRegExp.hasMatch(password) && password.isNotEmpty;
    final againPw = _controllerAgainPw.text;
    final isShowAgainTips = password != againPw && againPw.isNotEmpty;

    setState(() {
      isShowAccountTips = showAccountTips;
      _isLoginDisable = account.isEmpty ||
          showAccountTips ||
          (typeIndex != 1 && (code.isEmpty || isShowCodeTips)) ||
          password.isEmpty ||
          isShowPwTips ||
          againPw.isEmpty ||
          isShowAgainTips ||
          !_didAgreeTerms.value;
    });
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.w),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TypeSelector(
                    typeList: typeList,
                    typeIndex: typeIndex,
                    onTypeSelected: (index) {
                      setState(() {
                        typeIndex = index;
                        checkValid();
                      });
                    },
                  ),
                  SizedBox(height: 12.w),
                  Container(
                    height: 40.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: '#f5f5f5'.hexColor,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: [
                        if (isMobile)
                          Text(
                            '+86 丨 ',
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                          ),
                        Expanded(
                          child: TextField(
                            focusNode: _focusEmail,
                            keyboardType: TextInputType.text,
                            controller: _controllerEmail,
                            inputFormatters: [if (isMobile) FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: accountHint,
                              hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
                              contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                            ),
                            onChanged: (text) {
                              if (text.contains(' ')) {
                                String newText = text.replaceAll(' ', '');
                                _controllerEmail.text = newText;
                                _controllerEmail.selection = TextSelection.collapsed(offset: newText.length);
                              }
                              onChangeCheckValid();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: isShowAccountTips ? EdgeInsets.symmetric(vertical: 3.w) : EdgeInsets.zero,
                    child: Text(
                      isShowAccountTips ? accountTips : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  if (typeIndex != 1) ...[
                    Container(
                      height: 40.w,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _controllerCode,
                              focusNode: _focusCode,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请输入验证码',
                                hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
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
                      padding: isShowCodeTips ? EdgeInsets.symmetric(vertical: 3.w) : EdgeInsets.zero,
                      child: Text(
                        isShowCodeTips ? '*验证码错误' : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    height: 40.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                            focusNode: _focusPw,
                            obscureText: !_isVisible,
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请输入密码',
                              hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
                              contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                            ),
                            onChanged: (_) {
                              onChangeCheckValid();
                            },
                          ),
                        ),
                        GestureDetector(
                          child: Image.asset(
                            _isVisible ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
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
                    padding: EdgeInsets.symmetric(vertical: 6.w),
                    child: Text(
                      isShowPwTips
                          ? isContainsInvalidChars
                              ? '*仅允许英文字母、数字及特殊字符如@#\$%!'
                              : '*至少包含一位大小写字母+数字'
                          : '*8-12字符，至少包含大小写字母+数字',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 40.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: '#f5f5f5'.hexColor,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controllerAgainPw,
                            focusNode: _focusAgainPw,
                            obscureText: !_isVisibleAgain,
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            decoration: InputDecoration(
                              border: InputBorder.none, // 没有边框
                              hintText: '请再次输入密码',
                              hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
                              contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                            ),
                            onChanged: (_) {
                              onChangeCheckValid();
                            },
                          ),
                        ),
                        GestureDetector(
                          child: Image.asset(
                            _isVisibleAgain ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
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
                    padding: EdgeInsets.symmetric(vertical: 6.w),
                    child: Text(
                      isShowAgainTips ? '两次输入的密码不一致' : '*8-12字符，至少包含大小写字母+数字',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: UserTerms(
                          onTermsCheck: onTermsCheck,
                          didAgreeTerms: didAgreeTerms,
                          reviewTerms: reviewTerms,
                          reviewPrivacy: reviewPrivacy,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.forgetPassword);
                        },
                        child: Text(
                          '忘记密码?',
                          style: TextStyle(fontSize: 12.sp, color: '#557BF6'.hexColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.w),
          CustomButton(
            onPressed: register,
            disable: _isLoginDisable,
            showOpacityAnimation: true,
            textColor: Colors.white,
            height: 42.w,
            title: '注册',
          ),
          SizedBox(height: 20.w),
          goLogin(),
          SizedBox(height: 24.w),
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
              style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
            ),
            Text(
              '去登录',
              style: TextStyle(fontSize: 12.sp, color: '#557BF6'.hexColor),
            ),
          ],
        ),
      ),
    );
  }

  void register() {
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
    NetRequest().registerAccount(email, password, code, (data) {
      LoginHelper().userLogin(email, password, (data) {
        Get.back();
        Get.delete<CountDownController>(tag: NetRequest.SEND_CODE_TYPE_REGISTER, force: true);
      });
    });
  }

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
}
