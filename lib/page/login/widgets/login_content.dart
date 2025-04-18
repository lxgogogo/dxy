import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/user_terms_uncheck.dart';
import 'package:holdem/routes/app_pages.dart';

import '../../../constants.dart';
import '../../../model/user.dart';
import '../../../services/index.dart';
import '../../../stores/storage.dart';
import '../../../stores/user_store.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/toast_utils.dart';
import '../login_screen.dart';
import 'type_selector.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({
    Key? key,
    required this.buttonBuilder,
  }) : super(key: key);
  final CustomButtonBuilder buttonBuilder;

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  int typeIndex = 0;

  LoginType get type => LoginType.values[typeIndex];

  bool get isPhone => type == LoginType.phone;

  bool get isUsername => type == LoginType.username;

  final TextEditingController _controllerAccount = TextEditingController();
  bool isShowAccountTips = false;

  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  bool isLogin = true;
  bool isOpen = false;

  final FocusNode _focusAccount = FocusNode();
  final FocusNode _focusPwd = FocusNode();

  bool _isLoginDisable = true;

  void checkValid() {
    final account = _controllerAccount.text;
    switch (type) {
      case LoginType.email:
        isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case LoginType.phone:
        isShowAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case LoginType.username:
        isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }
    final password = _controllerPw.text;
    isShowPwTips = !Constants.passwordRegExp.hasMatch(password) && password.isNotEmpty;
    _isLoginDisable = account.isEmpty || isShowAccountTips || password.isEmpty || isShowPwTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerAccount.text;
    bool showAccountTips = false;
    switch (type) {
      case LoginType.email:
        showAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
      case LoginType.phone:
        showAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
      case LoginType.username:
        showAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
    }

    final password = _controllerPw.text;
    final showPwTips = !Constants.passwordRegExp.hasMatch(password) && password.isNotEmpty;
    _isLoginDisable = account.isEmpty || showAccountTips || password.isEmpty || showPwTips;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focusAccount.addListener(() {
      if (!_focusAccount.hasFocus) {
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.w),
                  TypeSelector(
                    typeList: LoginType.values.map((e) => e.typeName).toList(),
                    typeIndex: typeIndex,
                    onTypeSelected: (index) {
                      if (typeIndex != index) {
                        _controllerAccount.clear();
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
                    padding: isShowAccountTips ? EdgeInsets.symmetric(vertical: 3.w) : EdgeInsets.zero,
                    child: Text(
                      isShowAccountTips ? type.tips : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
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
                            controller: _controllerPw,
                            focusNode: _focusPwd,
                            obscureText: !isOpen,
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              isDense: true,
                              hintText: '密码',
                              hintStyle: TextStyle(fontSize: 12.sp, color: '#bfbfbf'.hexColor),
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
                            isOpen ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
                            width: 18.w,
                            height: 18.w,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: isShowPwTips ? EdgeInsets.symmetric(vertical: 3.w) : EdgeInsets.zero,
                    child: Text(
                      isShowPwTips ? '*8-12位，须包含大小写字母+数字' : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isShowPwTips ? Colors.red : '#95A3C4'.hexColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: UserTermsUncheck(
                          reviewTerms: reviewTerms,
                          reviewPrivacy: reviewPrivacy,
                        ),
                      ),
                      if (!isUsername)
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
          widget.buttonBuilder(onPressed: login, disable: _isLoginDisable),
        ],
      ),
    );
  }

  Future<void> login() async {
    // final captcha = await CaptchaStore.of.verify();
    // if (captcha.isEmpty) return;
    final account = _controllerAccount.text;
    final password = _controllerPw.text;
    final res = await LoginService.of.login(
      account: account,
      password: password,
      accountType: type.typeValue,
    );
    if (res.isSuccess) {
      ToastUtils.showToast('登录成功');
      StorageService.of.putToken(res.data['token']);
      final userProfile = UserProfile.fromJson(res.data['user']);
      UserStore.of.putUserInfo(userProfile);
      EventBusUtil.of.fire(EventLoginSuccess());
      Get.until((route) => route.settings.name == Routes.main);
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
