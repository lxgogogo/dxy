import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/widget/button.dart';

import '../../constants.dart';
import '../../services/index.dart';
import '../../widget/close_image_button.dart';
import '../login/login_screen.dart';
import '../login/widgets/type_selector.dart';

part 'forget_password_controller.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  List<LoginType> loginTypes = [
    LoginType.email,
    LoginType.phone,
  ];

  int typeIndex = 0;

  LoginType get type => loginTypes[typeIndex];

  bool get isPhone => type == LoginType.phone;

  bool _isVisible = false;
  bool _isVisibleAgain = false;

  final TextEditingController _controllerAccount = TextEditingController();
  bool isShowAccountTips = false;
  final FocusNode _focusAccount = FocusNode();
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

  void checkValid() {
    final account = _controllerAccount.text;
    switch (type) {
      case LoginType.email:
        isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case LoginType.username:
        isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case LoginType.phone:
        isShowAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }
    final code = _controllerCode.text;
    isShowCodeTips = type != LoginType.username && !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;
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
        (type != LoginType.username && (code.isEmpty || isShowCodeTips)) ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerAccount.text;
    bool showAccountTips = false;
    switch (type) {
      case LoginType.email:
        showAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case LoginType.username:
        showAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case LoginType.phone:
        showAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }
    final code = _controllerCode.text;
    final isShowCodeTips = type != LoginType.username && !Constants.codeRegExp.hasMatch(code) && code.isNotEmpty;
    final password = _controllerPw.text;
    final isShowPwTips = !Constants.passwordRegExp.hasMatch(password) && password.isNotEmpty;
    final againPw = _controllerAgainPw.text;
    final isShowAgainTips = password != againPw && againPw.isNotEmpty;

    _isLoginDisable = account.isEmpty ||
        showAccountTips ||
        (type != LoginType.username && (code.isEmpty || isShowCodeTips)) ||
        password.isEmpty ||
        isShowPwTips ||
        againPw.isEmpty ||
        isShowAgainTips;
    setState(() {});
  }

  String get verifyType => switch (type) {
        LoginType.email => Constants.verifyTypeEmail,
        LoginType.phone => Constants.verifyTypePhone,
        _ => '',
      };

  String get verifyCodeType => Constants.verifyCodeTypeResetPassword;

  @override
  void initState() {
    super.initState();
    _focusAccount.addListener(() {
      if (!_focusAccount.hasFocus) {
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
  Widget build(BuildContext context) {
    double inputHeight = 44.w;
    double tipsSpace = 8.w;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                    'assets/images/login_bg.png',
                  width: 1.sw,
                  height: 137.w,
                  fit: BoxFit.fitWidth,
                ),
                Positioned(
                  child: SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.w),
                      width: context.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: 96.w,
                            height: 20.w,
                          ),
                          CloseImageButton(
                            width: 16.w,
                            height: 16.w,
                            padding: EdgeInsets.all(16.w).copyWith(top: 0),
                            onTap: Get.back,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 24.w),
              child: Column(
                children: [
                  Text(
                    '忘记密码',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: '#333333'.hexColor,
                    ),
                  ),
                  Container(
                    width: 21.w,
                    height: 4.w,
                    margin: EdgeInsets.only(top: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(1.5.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24.w),
                    TypeSelector(
                      typeList: loginTypes.map((e) => e.typeOtherName2).toList(),
                      typeIndex: typeIndex,
                      onTypeSelected: (index) {
                        if (typeIndex != index) {
                          _controllerAccount.clear();
                          _controllerCode.clear();
                          _controllerPw.clear();
                          _controllerAgainPw.clear();
                          typeIndex = index;
                          checkValid();
                        }
                      },
                    ),
                    SizedBox(height: 16.w),
                    Container(
                      height: inputHeight,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: <Widget>[
                          if (isPhone)
                            Text(
                              '+86 丨 ',
                              style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            ),
                          Expanded(
                            child: TextField(
                              focusNode: _focusAccount,
                              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                              controller: _controllerAccount,
                              style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                              inputFormatters: [
                                if (isPhone) ...[
                                  LengthLimitingTextInputFormatter(11),
                                  FilteringTextInputFormatter.digitsOnly,
                                ]
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                isDense: true,
                                hintText: type.hint,
                                hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
                                contentPadding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                              ),
                              onChanged: (text) {
                                if (text.contains(' ')) {
                                  String newText = text.replaceAll(' ', '');
                                  _controllerAccount.text = newText;
                                  _controllerAccount.selection = TextSelection.collapsed(offset: newText.length);
                                }
                                onChangeCheckValid();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: isShowAccountTips ? EdgeInsets.symmetric(vertical: tipsSpace) : EdgeInsets.zero,
                      child: Text(
                        isShowAccountTips ? type.tips : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                        ),
                      )
                    ),
                    if (type != LoginType.username) ...[
                      Container(
                        height: inputHeight,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: '#f5f5f5'.hexColor,
                          borderRadius: BorderRadius.circular(12.r),
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
                                  isCollapsed: true,
                                  isDense: true,
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
                              verifyType: verifyType,
                              verifyCodeType: verifyCodeType,
                              account: _controllerAccount.text,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: isShowCodeTips ? EdgeInsets.symmetric(vertical: tipsSpace) : EdgeInsets.zero,
                        child: Text(
                          isShowCodeTips ? '*验证码错误' : '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        )
                      ),
                    ],
                    Container(
                      height: inputHeight,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.r),
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
                                isCollapsed: true,
                                isDense: true,
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
                      padding: EdgeInsets.symmetric(vertical: tipsSpace),
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
                      )
                    ),
                    Container(
                      height: inputHeight,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: '#f5f5f5'.hexColor,
                        borderRadius: BorderRadius.circular(12.r),
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
                                border: InputBorder.none,
                                isCollapsed: true,
                                isDense: true,
                                hintText: '再次输入新密码',
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
                        padding: EdgeInsets.symmetric(vertical: tipsSpace),
                        child: Text(
                          isShowAgainTips ? '*两次输入的密码不一致' : '*8-12字符，至少包含大小写字母+数字',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isShowAgainTips ? Colors.red : '#95A3C4'.hexColor,
                          ),
                        )),
                    SizedBox(height: 24.w),
                    CustomButton(
                      onPressed: registerOrConfirm,
                      disable: _isLoginDisable,
                      textColor: Colors.white,
                      height: 48.w,
                      radius: 8.w,
                      title: '找回密码',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void registerOrConfirm() async {
    var account = _controllerAccount.text;
    if (account.isEmpty) {
      DialogUtil.showToast('邮箱不能为空');
      return;
    }
    var code = _controllerCode.text;
    if (type != LoginType.username) {
      if (code.isEmpty) {
        DialogUtil.showToast('验证码不能为空');
        return;
      }
    }
    var password = _controllerPw.text;
    if (password.isEmpty) {
      DialogUtil.showToast('密码不能为空');
      return;
    }
    var againPassword = _controllerAgainPw.text;
    if (againPassword.isEmpty) {
      DialogUtil.showToast('请输入确认密码');
      return;
    }
    if (password != againPassword) {
      DialogUtil.showToast('两次输入的密码不一致');
      return;
    }
    final res = await LoginService.of.resetPassword(
      verifyType: verifyType,
      account: account,
      password: password,
      code: code,
    );
    if (res.isSuccess) {
      DialogUtil.showToast('重置密码成功');
      Get.back();
      Get.delete<CountDownController>(tag: '$verifyType$verifyCodeType', force: true);
    } else {
      DialogUtil.showToast(res.msg);
    }
  }
}
