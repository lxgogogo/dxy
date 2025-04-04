import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/login/widgets/register_content.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/close_image_button.dart';

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
                          )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
