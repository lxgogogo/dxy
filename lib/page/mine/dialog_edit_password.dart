import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';
import 'package:oktoast/oktoast.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../view/forum/ToastUtils.dart';

class DialogEditPassword extends StatefulWidget {
  const DialogEditPassword({super.key});

  @override
  State<DialogEditPassword> createState() => _DialogEditPasswordState();
}

class _DialogEditPasswordState extends State<DialogEditPassword> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController originalController = TextEditingController();
  bool _originalPwdObscureText = true;
  final TextEditingController newController = TextEditingController();
  bool _newPwdObscureText = true;
  bool isShowNewPasswordTips = false;
  final TextEditingController confirmController = TextEditingController();
  bool isShowConfirmPasswordTips = false;
  bool _confirmPwdObscureText = true;
  String confirmTips = '';

  int minLimit = 8;
  int maxLimit = 12;
  final RegExp regExp = RegExp(r'[A-Za-z]|[0-9]');

  @override
  void initState() {
    super.initState();
    newController.addListener(checkInvalid);
    confirmController.addListener(checkInvalid);
  }

  void checkInvalid() {
    if (newController.text.length >= minLimit) {
      isShowNewPasswordTips = false;
    } else {
      isShowNewPasswordTips = true;
    }

    if (newController.text != confirmController.text && confirmController.text.isNotEmpty) {
      isShowConfirmPasswordTips = true;
    } else {
      isShowConfirmPasswordTips = false;
    }
    _isDisable = isShowNewPasswordTips || isShowConfirmPasswordTips || confirmController.text.isEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ShadowWrapper(
          borderRadius: 10.5.px,
          margin: EdgeInsets.only(left: 18.px, right: 18.px),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.px),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.px,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "修改密码",
                          style: TextStyle(
                            color: const Color(0xff3b5078),
                            fontSize: 17.px,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.px,
                      top: 10.px,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          "assets/svg/icon_close.svg",
                          width: 28.px,
                          height: 28.px,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21.5.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          buildTitleText('原密码'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: originalController,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                obscureText: _originalPwdObscureText,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入原密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _originalPwdObscureText = !_originalPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _originalPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 11.px),
                      Row(
                        children: [
                          buildTitleText('新密码'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: newController,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(maxLimit),
                                ],
                                obscureText: _newPwdObscureText,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入新密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _newPwdObscureText = !_newPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _newPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isShowNewPasswordTips)
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.px, 8.px, 12.px, 0),
                          child: Text(
                            '密码为$minLimit-$maxLimit位字母和数字组合',
                            style: const TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 11.px),
                      Row(
                        children: [
                          buildTitleText('再次输入'),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: confirmController,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(maxLimit),
                                ],
                                obscureText: _confirmPwdObscureText,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请再次输入密码',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  suffix: UnconstrainedBox(
                                    child: CustomObscure(
                                      onTap: () {
                                        _confirmPwdObscureText = !_confirmPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _confirmPwdObscureText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isShowConfirmPasswordTips)
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.px, 8.px, 12.px, 0),
                          child: const Text(
                            '两次密码输入不一致',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 18.5.px),
                      CustomButton(
                        onPressed: _submitUpdate,
                        disable: _isDisable,
                        height: 42.px,
                        title: '确认',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitleText(String title) {
    return Stack(
      children: [
        Opacity(
          opacity: 0,
          child: Text(
            '四字占位',
            style: TextStyle(
              color: const Color(0xff3b5078),
              fontSize: 15.px,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xff3b5078),
            fontSize: 15.px,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _submitUpdate() {
    if (newController.text != confirmController.text) {
      showToast('两次密码不一致');
      return;
    }
    if (!regExp.hasMatch(newController.text)) {
      showToast('请输入8~12位字母数字组合的密码');
      return;
    }
    if (_isDisable) {
      return;
    }
    NetRequest().updatePassword(originalController.text, newController.text, (data) {
      ToastUtils.showToast('修改密码成功');
      //保存账号密码，获取本人信息接口需要
      StorageUtil().prefs!.setString('userPw', newController.text);
      Navigator.of(context).pop();
    });
  }
}

class CustomObscure extends StatelessWidget {
  final VoidCallback? onTap;
  final bool obscureText;

  const CustomObscure({super.key, this.onTap, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(
        obscureText ? 'assets/images/eye_open.png' : 'assets/images/eye_close.png',
        width: 18.px,
      ),
    );
  }
}
