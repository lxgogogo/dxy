import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/register_content.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/config_store.dart';
import 'package:holdem/widget/close_image_button.dart';

import '../../gen/assets.gen.dart';
import '../../model/user.dart';
import '../../services/index.dart';
import '../../stores/storage.dart';
import '../../stores/user_store.dart';
import '../../utils/app_version_checker.dart';
import '../../utils/env.dart';
import '../../utils/event_bus_util.dart';
import '../../utils/toast_utils.dart';
import '../../widget/button.dart';
import 'widgets/login_content.dart';

part 'login_controller.dart';

enum LoginType {
  email('邮箱登录', '邮箱注册', '邮箱找回密码', 'EMAIL', '*请输入正确邮箱地址', '邮箱地址'),
  username('账号登录', '账号注册', '账号找回密码', 'USERNAME', '*6-15位，允许输入英文大小写字母、数字', '账号'),
  phone('手机号登录', '手机号注册', '手机号找回密码', 'PHONE', '*手机号格式错误', '手机号');

  final String typeName;
  final String typeOtherName;
  final String typeOtherName2;
  final String typeValue;
  final String tips;
  final String hint;

  const LoginType(
    this.typeName,
    this.typeOtherName,
    this.typeOtherName2,
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

  bool isAuthorizing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppVersionChecker.of.checkVersion();
    });
  }

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
            Future.delayed(const Duration(milliseconds: 150), () {
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
                                fontSize: isLogin ? 18.sp : 14.sp,
                                fontWeight: isLogin ? FontWeight.w600 : FontWeight.w400,
                                color: isLogin ? '#333333'.hexColor : '#333333'.hexColor,
                              ),
                            ),
                            Container(
                              width: 12.w,
                              height: 2.w,
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
                                fontSize: isLogin ? 14.sp : 18.sp,
                                fontWeight: !isLogin ? FontWeight.w600 : FontWeight.w400,
                                color: !isLogin ? '#333333'.hexColor : '#333333'.hexColor,
                              ),
                            ),
                            Container(
                              width: 12.w,
                              height: 2.w,
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
                height: 50.w,
                radius: 8.w,
                title: isLogin ? '登录' : '注册',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
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
                        isLogin ? '没有账号？' : '已有账号？',
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
              SizedBox(height: 38.w),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildThirdLogin() {
    return Obx(() {
      if (ConfigStore.of.isOutsideTheWall.isFalse) {
        return const SizedBox();
      }
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
                  if (!Env.isAndroidAAb) ...[
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
                    onTap: signInWithTelegram,
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
    });
  }

  Future<void> signInWithGoogle() async {
    if (Env.isAndroidAAb) {
      await thirdWebLogin('GOOGLE', Env.googleLogin);
      return;
    }
    if (isAuthorizing) return;
    isAuthorizing = true;
    try {
      final googleUser = await GoogleSignIn().signIn();
      EasyLoading.show();
      final googleAuth = await googleUser?.authentication;
      if (googleAuth == null) return;
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
      if (res.isSuccess) {
        ToastUtils.showToast('登录成功');
        UserStore.of.loginSuccess(res);
        Get.until((route) => route.settings.name == Routes.main);
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (!e.code.contains('canceled')) {
          ToastUtils.showToast(e.message.toString());
        }
      } else {
        ToastUtils.showToast(e.toString());
      }
    } finally {
      EasyLoading.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> signInWithApple() async {
    if (Env.isAndroidAAb) {
      await thirdWebLogin('APPLE', Env.appleLogin);
      return;
    }
    if (isAuthorizing) return;
    isAuthorizing = true;
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      EasyLoading.show();
      final idTokenResult = await auth.user?.getIdTokenResult(true);
      final res = await LoginService.of.thirdLogin(
        type: 'APPLE',
        token: idTokenResult?.token ?? '',
      );
      if (res.isSuccess) {
        ToastUtils.showToast('登录成功');
        UserStore.of.loginSuccess(res);
        Get.until((route) => route.settings.name == Routes.main);
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // if (e.code != 'canceled' && e.code != 'web-context-canceled') {
        if (!e.code.contains('canceled')) {
          ToastUtils.showToast(e.message.toString());
        }
      } else {
        ToastUtils.showToast(e.toString());
      }
    } finally {
      EasyLoading.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> signInWithTelegram() async {
    if (isAuthorizing) return;
    isAuthorizing = true;
    try {
      final token = await Get.toNamed(
        Routes.webLogin,
        arguments: {'type': 'TELEGRAM', 'authUrl': Env.telegramLogin},
      )?.whenComplete(() {
        EasyLoading.dismiss();
      });
      if (token is String) {
        EasyLoading.show();
        final res = await LoginService.of.thirdLogin(
          type: 'TELEGRAM',
          token: token,
        );
        if (res.isSuccess) {
          ToastUtils.showToast('登录成功');
          UserStore.of.loginSuccess(res);
          Get.until((route) => route.settings.name == Routes.main);
        } else {
          ToastUtils.showToast(res.msg);
        }
      }
    } catch (e) {
      ToastUtils.showToast(e.toString());
    } finally {
      EasyLoading.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> thirdWebLogin(
    String type,
    String url,
  ) async {
    if (isAuthorizing) return;
    isAuthorizing = true;
    try {
      final token = await Get.toNamed(
        Routes.webLogin,
        arguments: {'type': type, 'authUrl': url},
      )?.whenComplete(() {
        EasyLoading.dismiss();
      });
      if (token is String) {
        EasyLoading.show();
        final res = await LoginService.of.thirdLogin(
          type: type,
          token: token,
          isOrigin: true,
        );
        if (res.isSuccess) {
          ToastUtils.showToast('登录成功');
          UserStore.of.loginSuccess(res);
          Get.until((route) => route.settings.name == Routes.main);
        } else {
          ToastUtils.showToast(res.msg);
        }
      }
    } catch (e) {
      ToastUtils.showToast(e.toString());
    } finally {
      EasyLoading.dismiss();
      isAuthorizing = false;
    }
  }
}
