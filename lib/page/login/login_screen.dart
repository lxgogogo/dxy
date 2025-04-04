import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/register_content.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/close_image_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/user_terms_uncheck.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../gen/assets.gen.dart';
import '../../model/user.dart';
import '../../services/index.dart';
import '../../stores/storage.dart';
import '../../stores/user_store.dart';
import '../../utils/event_bus_util.dart';
import '../../utils/toast_utils.dart';
import 'widgets/login_content.dart';

part 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Column(
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
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
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
                  child: isLogin
                      ? LoginContent(
                          goRegister: () {
                            setState(() {
                              isLogin = false;
                            });
                          },
                        )
                      : RegisterContent(
                          goLogin: () {
                            setState(() {
                              isLogin = true;
                            });
                          },
                        ),
                ),
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
                SizedBox(height: 36.w),
              ],
            ),
          ],
        ),
      ),
    );
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
          final res = await LoginService.of.thirdLogin(
            type: 'GOOGLE',
            token: idTokenResult.token ?? '',
          );
          if (res.isSuccess) {
            ToastUtils.showToast('登录成功');
            StorageService.of.putToken(res.data['token']);
            final userProfile = UserProfile.fromJson(res.data['user']);
            UserStore.of.putUserInfo(userProfile);
            EventBusUtil.of.fire(EventLoginSuccess());
            Get.until((route) => route.settings.name == Routes.main);
          } else {
            ToastUtils.showToast(res.msg ?? '');
          }
        }
      } catch (e) {
        ToastUtils.showToast('登录失败');
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
      final res = await LoginService.of.thirdLogin(
        type: 'APPLE',
        token: credential.identityToken ?? '',
      );
      if (res.isSuccess) {
        ToastUtils.showToast('登录成功');
        StorageService.of.putToken(res.data['token']);
        final userProfile = UserProfile.fromJson(res.data['user']);
        UserStore.of.putUserInfo(userProfile);
        EventBusUtil.of.fire(EventLoginSuccess());
        Get.until((route) => route.settings.name == Routes.main);
      } else {
        ToastUtils.showToast(res.msg ?? '');
      }
    } catch (e) {
      ToastUtils.showToast('登录失败');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
