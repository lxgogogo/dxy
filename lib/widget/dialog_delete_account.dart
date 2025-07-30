import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../constants.dart';
import '../services/index.dart';
import '../utils/event_bus_util.dart';
import '../utils/dialog_util.dart';
import 'close_image_button.dart';

class DialogDeleteAccount extends StatefulWidget {
  const DialogDeleteAccount({super.key});

  @override
  State<DialogDeleteAccount> createState() => _DialogDeleteAccountState();
}

class _DialogDeleteAccountState extends State<DialogDeleteAccount> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final FocusNode _focusEmail = FocusNode();

  final String deleteText = 'DELETE ACCOUNT';

  void checkValid() {
    final account = _controllerEmail.text;
    _isDisable = account.isEmpty || account != deleteText;
    setState(() {});
  }

  void onChangeCheckValid() {
    final account = _controllerEmail.text;
    _isDisable = account.isEmpty || account != deleteText;
    setState(() {});
  }

  String get verifyType => Constants.verifyTypeEmail;

  String get verifyCodeType => Constants.verifyCodeTypeDeleteAccount;

  @override
  void initState() {
    super.initState();
    _focusEmail.addListener(() {
      if (!_focusEmail.hasFocus) {
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
          borderRadius: 10.5.w,
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
                          "注销账号",
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CloseImageButton(
                        color: '#333333'.hexColor.withOpacity(0.5),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: '请在下方输入',
                    children: [
                      TextSpan(
                        text: '"$deleteText"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '\n确认删除您的帐号'),
                    ],
                  ),
                  style: TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 30.w,
                  margin: EdgeInsets.fromLTRB(40.w, 24.w, 40.w, 36.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
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
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                      hintText: '',
                      hintStyle: TextStyle(
                        color: '#3333334D'.hexColor,
                        fontSize: 12.sp,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    onChanged: (text) {
                      onChangeCheckValid();
                    },
                  ),
                ),
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
                    AnimatedOpacity(
                      opacity: _isDisable ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: InkWell(
                        onTap: _submit,
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
                            '确定注销',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_isDisable) {
      DialogUtil.showToast('请输入$deleteText');
      return;
    }
    final res = await UserService.of.deleteAccount();
    if (res.isSuccess) {
      DialogUtil.showToast('注销成功');
      EventBusUtil.of.fire(EventLogout());
      UserStore.of.clearUserStorage();
      Get.until((route) => route.settings.name == Routes.main);
    } else {
      DialogUtil.showToast(res.msg);
    }
  }
}
