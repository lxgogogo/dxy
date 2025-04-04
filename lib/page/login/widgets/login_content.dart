import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/user_terms.dart';
import 'package:holdem/page/login/widgets/user_terms_uncheck.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/widget/button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../constants.dart';
import '../../../gen/assets.gen.dart';
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
          SizedBox(
            height: 30.w,
          ),
          SingleChildScrollView(
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
                  height: 44.w,
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
                  height: 44.w,
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
              ],
            ),
          ),
          SizedBox(height: 8.w),
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
          SizedBox(height: 36.w),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: signInWithGoogle,
                child: Assets.images.iconGoogleCircle.image(
                  width: 36.w,
                  height: 36.w,
                ),
              ),
              SizedBox(width: 36.w),
              GestureDetector(
                onTap: signInWithApple,
                child: Assets.images.iconAppleCircle.image(
                  width: 36.w,
                  height: 36.w,
                ),
              ),
              SizedBox(width: 36.w),
              GestureDetector(
                child: Assets.images.iconTelegramCircle.image(
                  width: 36.w,
                  height: 36.w,
                ),
              ),
            ],
          ),
          SizedBox(width: 36.w),
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

  void login() {
    var account = _controllerAccount.text;
    var password = _controllerPw.text;
    LoginHelper().userLogin(account, password, (data) {
      Get.until((route) => route.settings.name == Routes.main);
    });
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      EasyLoading.show(status: 'loading...');
      try {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final idTokenResult = await userCredential.user?.getIdTokenResult(true);
        if (idTokenResult != null) {
          final userId = idTokenResult.claims?['user_id'] as String? ?? '';
          final name = idTokenResult.claims?['name'] as String? ?? '';
          final email = idTokenResult.claims?['email'] as String? ?? '';
          final picture = idTokenResult.claims?['picture'] as String? ?? '';
          final token = idTokenResult.token ?? '';
          // final res = await AccountAPI.otherLogin(
          //   type: OtherLoginType.google,
          //   userId: userId,
          //   name: name,
          //   email: email,
          //   picture: picture,
          //   token: token,
          // );
          // if (res.code == 0 && res.data != null) {
          //   final tokenModel =
          //   TokenModel.fromJson(res.data as Map<String, dynamic>? ?? {});
          //   await UserStore.to.setTokenModel(tokenModel);
          //   await UserStore.to.setUserInfo();
          //   Get.offAllNamed(Routes.main);
          //   CustomToast.success(res.msg ?? '');
          // } else {
          //   CustomToast.fail(res.msg ?? '');
          // }
        }
      } catch (e) {
        // CustomToast.fail(e.toString());
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    EasyLoading.show(status: 'loading...');
    try {
      final userId = credential.userIdentifier ?? '';
      final name = credential.givenName ?? '';
      final email = credential.email ?? '';
      final token = credential.identityToken ?? '';
      // final res = await AccountAPI.otherLogin(
      //   type: OtherLoginType.apple,
      //   userId: userId,
      //   name: name,
      //   email: email,
      //   token: token,
      // );
      // if (res.code == 0 && res.data != null) {
      //   final tokenModel =
      //   TokenModel.fromJson(res.data as Map<String, dynamic>? ?? {});
      //   await UserStore.to.setTokenModel(tokenModel);
      //   await UserStore.to.setUserInfo();
      //   Get.offAllNamed(Routes.main);
      //   CustomToast.success(res.msg ?? '');
      // } else {
      //   CustomToast.fail(res.msg ?? '');
      // }
    } catch (e) {
      // CustomToast.fail(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }
}
