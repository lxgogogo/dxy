import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/register_content.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/close_image_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../gen/assets.gen.dart';
import '../../model/user.dart';
import '../../services/index.dart';
import '../../stores/storage.dart';
import '../../stores/user_store.dart';
import '../../utils/event_bus_util.dart';
import '../../utils/toast_utils.dart';
import '../../widget/button.dart';
import 'widgets/login_content.dart';

part 'login_controller.dart';

enum LoginType {
  email('邮箱登录', '邮箱注册', 'EMAIL', '*请输入正确邮箱地址', '请输入邮箱'),
  username('账号登录', '账号注册', 'USERNAME', '*6~15位英数字，大小写不同', '请输入账号'),
  phone('手机登录', '手机注册', 'PHONE', '*手机号格式错误', '请输入手机号');

  final String typeName;
  final String typeOtherName;
  final String typeValue;
  final String tips;
  final String hint;

  const LoginType(
    this.typeName,
    this.typeOtherName,
    this.typeValue,
    this.tips,
    this.hint,
  );
}

typedef CustomButtonBuilder = Widget Function({VoidCallback? onPressed, bool? disable});

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ValueNotifier<bool> _showButtonNotifier = ValueNotifier(true);
  bool _isKeyboardVisible = false;

  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, bool isKeyboardVisible) {
        if (isKeyboardVisible != _isKeyboardVisible) {
          _isKeyboardVisible = isKeyboardVisible;
          if (isKeyboardVisible) {
            if (_showButtonNotifier.value) {
              _showButtonNotifier.value = false;
            }
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!_isKeyboardVisible && !_showButtonNotifier.value) {
                _showButtonNotifier.value = true;
              }
            });
          }
        }
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Image.asset('assets/images/login_bg.png'),
                    Positioned(
                      child: SafeArea(
                        child: Container(
                          margin: EdgeInsets.only(left: 10.w),
                          width: context.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 23.w,
                              ),
                              CloseImageButton(
                                width: 16.w,
                                height: 16.w,
                                padding: EdgeInsets.all(16.w),
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
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          isLogin = true;
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            Text(
                              '登录',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: isLogin ? FontWeight.w600 : FontWeight.w400,
                                color: isLogin ? '#333333'.hexColor : '#333333'.hexColor,
                              ),
                            ),
                            Container(
                              width: 21.w,
                              height: 4.w,
                              margin: EdgeInsets.only(top: 4.w),
                              decoration: BoxDecoration(
                                color: isLogin ? '#557BF6'.hexColor : Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(1.5.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLogin = false;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              '注册',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: !isLogin ? FontWeight.w600 : FontWeight.w400,
                                color: !isLogin ? '#333333'.hexColor : '#333333'.hexColor,
                              ),
                            ),
                            Container(
                              width: 21.w,
                              height: 4.w,
                              margin: EdgeInsets.only(top: 4.w),
                              decoration: BoxDecoration(
                                color: !isLogin ? '#557BF6'.hexColor : Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(1.5.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: isLogin
                            ? LoginContent(
                                buttonBuilder: _buildButton,
                              )
                            : RegisterContent(
                                buttonBuilder: _buildButton,
                              ),
                      ),
                      _buildThirdLogin(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({VoidCallback? onPressed, bool? disable}) {
    return ValueListenableBuilder(
      valueListenable: _showButtonNotifier,
      builder: (context, showButton, _) {
        if (showButton) {
          return Column(
            children: [
              CustomButton(
                onPressed: onPressed,
                disable: disable ?? false,
                showOpacityAnimation: true,
                textColor: Colors.white,
                height: 42.w,
                title: isLogin ? '登录' : '注册',
              ),
              SizedBox(height: 20.w),
              Center(
                child: GestureDetector(
                  onTap: () {
                    isLogin = !isLogin;
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '没有账号？',
                        style: TextStyle(fontSize: 12.sp, color: '#333333'.hexColor),
                      ),
                      Text(
                        isLogin ? '去注册' : '去登录',
                        style: TextStyle(fontSize: 12.sp, color: '#557BF6'.hexColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.w),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildThirdLogin() {
    return ValueListenableBuilder(
      valueListenable: _showButtonNotifier,
      builder: (context, showButton, _) {
        if (showButton) {
          return Padding(
            padding: EdgeInsets.only(bottom: 36.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: signInWithGoogle,
                  child: Assets.images.iconGoogleCircle.image(
                    width: 36.w,
                    height: 36.w,
                  ),
                ),
                if (Platform.isIOS) ...[
                  SizedBox(width: 36.w),
                  GestureDetector(
                    onTap: signInWithApple,
                    child: Assets.images.iconAppleCircle.image(
                      width: 36.w,
                      height: 36.w,
                    ),
                  ),
                ],
                SizedBox(width: 36.w),
                GestureDetector(
                  child: Assets.images.iconTelegramCircle.image(
                    width: 36.w,
                    height: 36.w,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      EasyLoading.show(status: 'loading...');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idTokenResult = await userCredential.user?.getIdTokenResult(true);
      final res = await LoginService.of.thirdLogin(
        type: 'GOOGLE',
        token: idTokenResult?.token ?? '',
      );
      EasyLoading.dismiss();
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

  Future<void> signInWithApple() async {
    // final credential = await SignInWithApple.getAppleIDCredential(
    //   scopes: [
    //     AppleIDAuthorizationScopes.email,
    //     AppleIDAuthorizationScopes.fullName,
    //   ],
    // );
    // EasyLoading.show(status: 'loading...');
    final appleProvider = AppleAuthProvider();
    final auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
    EasyLoading.show(status: 'loading...');
    final idTokenResult = await auth.user?.getIdTokenResult(true);
    final res = await LoginService.of.thirdLogin(
      type: 'APPLE',
      token: idTokenResult?.token ?? '',
    );
    // final res = await LoginService.of.thirdLogin(
    //   type: 'APPLE',
    //   token: credential.identityToken ?? '',
    // );
    EasyLoading.dismiss();
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
