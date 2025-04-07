import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/count_down/count_down_view.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../constants.dart';
import '../services/index.dart';
import '../utils/toast_utils.dart';
import 'close_image_button.dart';

class DialogEditEmail extends StatefulWidget {
  final String editContent; //
  const DialogEditEmail({super.key, required this.editContent});

  @override
  State<DialogEditEmail> createState() => _DialogEditEmailState();
}

class _DialogEditEmailState extends State<DialogEditEmail> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerEmail = TextEditingController();
  bool isShowAccountTips = false;
  final FocusNode _focusEmail = FocusNode();
  final TextEditingController _controllerCode = TextEditingController();
  bool isShowCodeTips = false;
  final FocusNode _focusCode = FocusNode();

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

  String get verifyType => Constants.verifyTypeEmail;

  String get verifyCodeType => Constants.verifyCodeTypeChangeEmail;

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
                          "修改邮箱",
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
                            "新邮箱",
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
                                controller: _controllerEmail,
                                focusNode: _focusEmail,
                                style: TextStyle(
                                  color: '#333333'.hexColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                  hintText: '请输入邮箱',
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
                                    _controllerEmail.text = newText;
                                    _controllerEmail.selection = TextSelection.collapsed(offset: newText.length);
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
                              "三个字",
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
                                isShowAccountTips ? '*请输入正确邮箱地址' : '',
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
                            "验证码",
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  TextField(
                                    controller: _controllerCode,
                                    focusNode: _focusCode,
                                    style: TextStyle(
                                      color: const Color(0xff3b5078),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                      hintText: '请输入验证码',
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
                                    onChanged: (_) {
                                      onChangeCheckValid();
                                    },
                                  ),
                                  Positioned(
                                    right: 12.w,
                                    child: CountDownView(
                                      account: _controllerEmail.text,
                                      verifyType: verifyType,
                                      verifyCodeType: verifyCodeType,
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
                          Opacity(
                            opacity: 0,
                            child: Text(
                              "三个字",
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
                      SizedBox(height: 26.w),
                      Container(
                        child: Row(
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

  Future<void> _submitUpdate() async {
    if (_isDisable) return;
    String email = _controllerEmail.text;
    String code = _controllerCode.text;
    try {
      final res = await UserService.of.updateEmail(
        email: email,
        code: code,
      );
      if (res.isSuccess) {
        ToastUtils.showToast('修改成功');
        UserStore.of.getUserInfo();
        Get.back();
        Get.delete<CountDownController>(tag: '$verifyType$verifyCodeType', force: true);
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      ToastUtils.showToast('修改失败');
    }
  }
}
