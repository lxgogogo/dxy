import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../utils/toast_utils.dart';

class DialogDeleteAccount extends StatefulWidget {
  const DialogDeleteAccount({super.key});

  @override
  State<DialogDeleteAccount> createState() => _DialogDeleteAccountState();
}

class _DialogDeleteAccountState extends State<DialogDeleteAccount> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerEmail = TextEditingController();
  bool isShowAccountTips = false;
  final FocusNode _focusEmail = FocusNode();
  final TextEditingController _controllerCode = TextEditingController();
  bool isShowCodeTips = false;
  final FocusNode _focusCode = FocusNode();

  int _countdown = 60;
  bool _isCountingDown = false;

  RegExp codeRegExp = RegExp(r'^\d{6}$');

  void checkValid() {
    final account = _controllerEmail.text;
    isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;

    _isDisable = account.isEmpty || isShowAccountTips || code.isEmpty || isShowCodeTips;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerEmail.text;
    final isShowAccountTips = !GetUtils.isEmail(account) && account.isNotEmpty;
    final code = _controllerCode.text;
    final isShowCodeTips = !codeRegExp.hasMatch(code) && code.isNotEmpty;

    _isDisable = account.isEmpty || isShowAccountTips || code.isEmpty || isShowCodeTips;
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
    _focusCode.addListener(() {
      if (!_focusCode.hasFocus) {
        checkValid();
      }
    });
  }

  void _startCountdown() {
    if (mounted) {
      setState(() {
        _isCountingDown = true;
        _countdown = 60;
      });
    }

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _isCountingDown = false;
            timer.cancel();
          }
        });
      }
    });
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
                          "注销账户",
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
                          SizedBox(
                            width: 68.5.px,
                            child: Text(
                              "邮箱",
                              style: TextStyle(
                                color: const Color(0xff3b5078),
                                fontSize: 15.px,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
                                controller: _controllerEmail,
                                focusNode: _focusEmail,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                    RegExp('[\\s]'),
                                  )
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入邮箱',
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
                                ),
                                onChanged: (_) {
                                  onChangeCheckValid();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 68.5.px),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              child: Text(
                                isShowAccountTips ? '请输入正确邮箱地址' : '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isShowAccountTips ? Colors.red : '#95A3C4'.hexColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 68.5.px,
                            child: Text(
                              "验证码",
                              style: TextStyle(
                                color: const Color(0xff3b5078),
                                fontSize: 15.px,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  TextField(
                                    controller: _controllerCode,
                                    focusNode: _focusCode,
                                    style: TextStyle(
                                      color: const Color(0xff3b5078),
                                      fontSize: 12.px,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                      hintText: '请输入验证码',
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
                                    ),
                                    onChanged: (_) {
                                      onChangeCheckValid();
                                    },
                                  ),
                                  Positioned(
                                    right: 12.px,
                                    child: _isCountingDown
                                        ? Text(
                                            '${_countdown}s',
                                            style: TextStyle(
                                              color: const Color(0xff249cfc),
                                              fontSize: 12.px,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: _sendCode,
                                            child: Text(
                                              "发送验证码",
                                              style: TextStyle(
                                                color: const Color(0xff249cfc),
                                                fontSize: 12.px,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 68.5.px),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              child: Text(
                                isShowCodeTips ? '请输入6位数字验证码' : '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isShowCodeTips ? Colors.red : '#95A3C4'.hexColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 42.px),
                      CustomButton(
                        onPressed: _submit,
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

  void _submit() {
    if (_isDisable) return;
    String email = _controllerEmail.text;
    String code = _controllerCode.text;
    NetRequest().deleteAccount(email, code, (data) {
      ToastUtils.showToast('注销成功');
      UserStore.of.clearUserStorage();
      Get.until((route) => route.settings.name == Routes.main);
      EventBusManager.eventBus.fire(EventBusAction.noticeMainTabSwitchHome.eventBusTypeName);
    });
  }

  void _sendCode() {
    var email = _controllerEmail.text;
    if (email.isEmpty) {
      ToastUtils.showToast('邮箱不能为空');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      ToastUtils.showToast('请输入正确格式邮箱');
      return;
    }
    _startCountdown();
    NetRequest().sendCode(
      NetRequest.SEND_CODE_DELETE_ACCOUNT,
      email,
      (data) {},
    );
  }
}
