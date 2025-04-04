import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/user_terms_uncheck.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/button.dart';

import '../../../constants.dart';
import '../../../model/user.dart';
import '../../../services/index.dart';
import '../../../stores/storage.dart';
import '../../../stores/user_store.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/toast_utils.dart';
import 'type_selector.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key, required this.goRegister}) : super(key: key);
  final Function goRegister;

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final List<String> typeList = ['邮箱登录', '账号登录', '手机登录'];
  int typeIndex = 0;

  String get type => typeList[typeIndex];

  bool get isMobile => typeIndex == 2;

  final TextEditingController _controllerAccount = TextEditingController();
  bool isShowAccountTips = false;

  String get accountTips {
    switch (typeIndex) {
      case 0: // 邮箱登录
        return '*请输入正确邮箱地址';
      case 1: // 账号登录
        return '*6~15位英数字，大小写不同';
      case 2: // 手机登录
        return '*手机号格式错误';
      default:
        return '';
    }
  }

  String get accountHint {
    switch (typeIndex) {
      case 0: // 邮箱登录
        return '请输入邮箱';
      case 1: // 账号登录
        return '请输入账号';
      case 2: // 手机登录
        return '请输入手机号';
      default:
        return '';
    }
  }

  final TextEditingController _controllerPw = TextEditingController();
  bool isShowPwTips = false;
  bool isLogin = true;
  bool isOpen = false;

  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPwd = FocusNode();

  bool _isLoginDisable = true;

  void checkValid() {
    final account = _controllerAccount.text;
    switch (typeIndex) {
      case 0: // 邮箱登录
        isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case 1: // 账号登录
        isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case 2: // 手机登录
        isShowAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
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
    switch (typeIndex) {
      case 0: // 邮箱登录
        showAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
        break;
      case 1: // 账号登录
        showAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
        break;
      case 2: // 手机登录
        showAccountTips = !Constants.phoneRegExp.hasMatch(account) && account.isNotEmpty;
        break;
    }

    final password = _controllerPw.text;
    final showPwTips = !Constants.passwordRegExp.hasMatch(password) && password.isNotEmpty;
    _isLoginDisable = account.isEmpty || showAccountTips || password.isEmpty || showPwTips;

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
                      typeIndex = index;
                      checkValid();
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
                            keyboardType: isMobile ? TextInputType.phone : TextInputType.text,
                            controller: _controllerAccount,
                            style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                            inputFormatters: [if (isMobile) FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              border: InputBorder.none, // 没有边框
                              hintText: accountHint,
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
                      isShowAccountTips ? accountTips : '',
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
                      borderRadius: BorderRadius.circular(12.w),
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
            onPressed: login,
            disable: _isLoginDisable,
            showOpacityAnimation: true,
            textColor: Colors.white,
            height: 42.w,
            title: '登录',
          ),
          SizedBox(height: 20.w),
          goRegister(),
          SizedBox(height: 24.w),
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
              style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
            ),
            Text(
              '去注册',
              style: TextStyle(fontSize: 12.sp, color: '#557BF6'.hexColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final account = _controllerAccount.text;
    final password = _controllerPw.text;
    EasyLoading.show(status: 'loading...');
    try {
      final res = await LoginService.of.login(account: account, password: password);
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
    } catch (e) {
      ToastUtils.showToast('登录失败');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
