import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../constants.dart';
import 'close_image_button.dart';
import 'dialog_edit_password.dart';

class DialogEditUsername extends StatefulWidget {
  final String editContent;

  const DialogEditUsername({super.key, required this.editContent});

  @override
  State<DialogEditUsername> createState() => _DialogEditUsernameState();
}

class _DialogEditUsernameState extends State<DialogEditUsername> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerAccount = TextEditingController();
  bool isShowAccountTips = false;
  final FocusNode _focusAccount = FocusNode();

  final TextEditingController _controllerOriginalPw = TextEditingController();
  bool _originalPwdObscureText = true;

  void checkValid() {
    final account = _controllerAccount.text;
    isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
    final originalPassword = _controllerOriginalPw.text;

    _isDisable = account.isEmpty || isShowAccountTips || originalPassword.isEmpty;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerAccount.text;
    final isShowAccountTips = !Constants.accountRegExp.hasMatch(account) && account.isNotEmpty;
    final originalPassword = _controllerOriginalPw.text;

    _isDisable = account.isEmpty || isShowAccountTips || originalPassword.isEmpty;
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
          borderRadius: 16.w,
          margin: EdgeInsets.only(left: 32.w, right: 32.w),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.w,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "修改账号",
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0.w,
                      top: 0.w,
                      child: CloseImageButton(
                        width: 16.w,
                        height: 16.w,
                        color: '#333333'.hexColor.withOpacity(0.5),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21.5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            "账号",
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              height: 30.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: '#333333'.hexColor.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: TextField(
                                controller: _controllerAccount,
                                focusNode: _focusAccount,
                                style: TextStyle(
                                  color: '#333333'.hexColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                  hintText: '请输入账号',
                                  hintStyle: TextStyle(
                                    color: '#3333334D'.hexColor,
                                    fontSize: 12.sp,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  disabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
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
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Opacity(
                            opacity: 0,
                            child: Text(
                              "账号",
                              style: TextStyle(
                                color: '#333333'.hexColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              child: Text(
                                isShowAccountTips ? '*6~15位英数字，大小写不同' : '',
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
                          Text(
                            "密码",
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 30.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: '#333333'.hexColor.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerOriginalPw,
                                      // focusNode: _focusOriginalPw,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      obscureText: _originalPwdObscureText,
                                      onChanged: (_) {
                                        onChangeCheckValid();
                                      },
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(left: 12.w),
                                        hintText: '请输入原密码',
                                        hintStyle: TextStyle(
                                          color: '#3333334D'.hexColor,
                                          fontSize: 12.sp,
                                        ),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        disabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: CustomObscure(
                                      onTap: () {
                                        _originalPwdObscureText = !_originalPwdObscureText;
                                        setState(() {});
                                      },
                                      obscureText: _originalPwdObscureText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 26.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 96.w,
                              height: 33.w,
                              decoration: ShapeDecoration(
                                color: '#333333'.hexColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: '#333333'.hexColor.withOpacity(0.7),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24.w),
                          InkWell(
                            onTap: _submitUpdate,
                            child: Container(
                              width: 96.w,
                              height: 33.w,
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(1.00, 0.00),
                                  end: Alignment(-1, 0),
                                  colors: [
                                    Color(0xFF84BCF9),
                                    Color(0xFF557BF6),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '确定修改',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _submitUpdate() {
    if (_isDisable) return;
    // String account = _controllerAccount.text;
    // String code = _controllerCode.text;
    // NetRequest().updateAccount(account, code, (data) {
    //   ToastUtils.showToast('修改成功');
    //   UserStore.of.getUserInfo();
    //   Get.back();
    //   Get.delete<CountDownController>(tag: NetRequest.SEND_CODE_TYPE_CHANGE_EMAIL, force: true);
    // });
  }
}
