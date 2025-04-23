import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/page/login/widgets/user_terms.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/button.dart';

import '../../../constants.dart';
import '../../../model/user.dart';
import '../../../services/index.dart';
import '../../../stores/storage.dart';
import '../../../stores/user_store.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/track_utils.dart';
import 'type_selector.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({Key? key, required this.buttonBuilder}) : super(key: key);
  final CustomButtonBuilder buttonBuilder;

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  int typeIndex = 0;

  LoginType get type => LoginType.values[typeIndex];

  bool get isPhone => type == LoginType.phone;

  bool get isUsername => type == LoginType.username;

  bool _isVisible = false;
  bool _isVisibleAgain = false;

  final TextEditingController _controllerAccount = TextEditingController();
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
  bool isContainsInvalidChars = false;

  ///隐私协议
  ValueNotifier<bool> get didAgreeTerms => _didAgreeTerms;
  late ValueNotifier<bool> _didAgreeTerms;

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
        isShowAgainTips ||
        !_didAgreeTerms.value;
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
        isShowAgainTips ||
        !_didAgreeTerms.value;
    setState(() {});
  }

  String get verifyType => switch (type) {
        LoginType.email => Constants.verifyTypeEmail,
        LoginType.phone => Constants.verifyTypePhone,
        _ => '',
      };

  String get verifyCodeType => Constants.verifyCodeTypeRegister;

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.w),
                  TypeSelector(
                    typeList: LoginType.values.map((e) => e.typeOtherName).toList(),
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
                  SizedBox(height: 12.w),
                  Container(
                    height: 40.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: '#f5f5f5'.hexColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        if (isPhone)
                          Text(
                            '+86 丨 ',
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                          ),
                        Expanded(
                          child: TextField(
                            focusNode: _focusEmail,
                            keyboardType: TextInputType.text,
                            controller: _controllerAccount,
                            inputFormatters: [
                              if (isPhone) ...[
                                LengthLimitingTextInputFormatter(11),
                                FilteringTextInputFormatter.digitsOnly,
                              ]
                            ],
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
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
                    padding: isShowAccountTips ? EdgeInsets.symmetric(vertical: 3.w) : EdgeInsets.zero,
                    child: Text(
                      isShowAccountTips ? type.tips : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  if (type != LoginType.username) ...[
                    Container(
                      height: 40.w,
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
                      isShowAgainTips ? '*两次输入的密码不一致' : '*8-12字符，至少包含大小写字母+数字',
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
                      if (!isUsername)
                        GestureDetector(
                          onTap: TrackUtils.trackedTap(
                            onTap: () {
                              Get.toNamed(Routes.forgetPassword);
                            },
                            userLogType: '118003',
                          ),
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
          widget.buttonBuilder(onPressed: register, disable: _isLoginDisable),
        ],
      ),
    );
  }

  Future<void> register() async {
    var account = _controllerAccount.text;
    if (account.isEmpty) {
      ToastUtils.showToast('邮箱不能为空');
      return;
    }
    var code = _controllerCode.text;
    if (type != LoginType.username) {
      if (code.isEmpty) {
        ToastUtils.showToast('验证码不能为空');
        return;
      }
    }
    var password = _controllerPw.text;
    if (password.isEmpty) {
      ToastUtils.showToast('密码不能为空');
      return;
    }
    var againPassword = _controllerAgainPw.text;
    if (againPassword.isEmpty) {
      ToastUtils.showToast('请输入确认密码');
      return;
    }
    if (password != againPassword) {
      ToastUtils.showToast('两次输入的密码不一致');
      return;
    }
    final res = await LoginService.of.register(
      accountType: type.typeValue,
      account: account,
      password: password,
      code: code,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('注册成功');
      StorageService.of.putToken(res.data['token']);
      final userProfile = UserProfile.fromJson(res.data['user']);
      UserStore.of.putUserInfo(userProfile);
      EventBusUtil.of.fire(EventLoginSuccess());
      Get.until((route) => route.settings.name == Routes.main);
      Get.delete<CountDownController>(tag: '$verifyType$verifyCodeType', force: true);
      // TrackUtils.trackEvent(userLogType: '118005');
    } else {
      ToastUtils.showToast(res.msg);
      // TrackUtils.trackEvent(userLogType: '118006');
    }
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
