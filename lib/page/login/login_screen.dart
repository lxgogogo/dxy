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
    return BackgroundContainer(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Image.asset('assets/images/login_bg.png'),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 30.w, top: 103.w, bottom: 44.5.w),
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 38.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50.w),
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
                                  fontSize: 18.sp,
                                  fontWeight: isLogin ? FontWeight.w500 : FontWeight.w400,
                                  color: isLogin ? '#249cfc'.hexColor : '#3b5078'.hexColor,
                                ),
                              ),
                              Container(
                                width: 21.w,
                                height: 2.5.w,
                                margin: EdgeInsets.only(top: 4.w),
                                decoration: BoxDecoration(
                                  color: isLogin ? '#249cfc'.hexColor : Colors.transparent,
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
                                  fontSize: 18.sp,
                                  fontWeight: !isLogin ? FontWeight.w500 : FontWeight.w400,
                                  color: !isLogin ? '#249cfc'.hexColor : '#3b5078'.hexColor,
                                ),
                              ),
                              Container(
                                width: 21.w,
                                height: 2.5.w,
                                margin: EdgeInsets.only(top: 4.w),
                                decoration: BoxDecoration(
                                  color: !isLogin ? '#249cfc'.hexColor : Colors.transparent,
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
                  if (isLogin) const LoginContent() else const RegisterContent()
                ],
              ),
            ),
            Positioned(
              top: 53.w,
              right: 15.w,
              child: CloseImageButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
