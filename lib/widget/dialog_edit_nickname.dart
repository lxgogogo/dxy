import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/input_limit_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../stores/user_store.dart';
import '../utils/toast_utils.dart';
import 'close_image_button.dart';

class DialogEditNickname extends StatefulWidget {
  final String editContent; //
  const DialogEditNickname({super.key, required this.editContent});

  @override
  State<DialogEditNickname> createState() => _DialogEditNicknameState();
}

class _DialogEditNicknameState extends State<DialogEditNickname> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isDisable = ValueNotifier(true);
  final ValueNotifier<int> _textLength = ValueNotifier(0);

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.editContent;
    controller.addListener(() {
      _textLength.value = controller.text.length;
      _isDisable.value = controller.text.isEmpty || controller.text == widget.editContent;
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
          margin: EdgeInsets.only(left: 18.w, right: 18.w),
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
                          "修改昵称",
                          style: TextStyle(
                            color: '#333333'.hexColor,
                            fontSize: 16.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 10.w,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            "新昵称",
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.w,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.w),
                                      border: Border.all(
                                        color: '#333333'.hexColor.withOpacity(0.2),
                                        width: 1.w,
                                      ),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: const Color(0xff709ac8).withOpacity(0.22),
                                      //   ),
                                      //   BoxShadow(
                                      //     color: const Color(0xffebf6ff),
                                      //     spreadRadius: -2.w,
                                      //     blurRadius: 5.w,
                                      //     offset: const Offset(1, 1),
                                      //   ),
                                      // ],
                                    ),
                                    child: TextField(
                                      controller: controller,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.w,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      inputFormatters: <TextInputFormatter>[
                                        CustomizedLengthTextInputFormatter(10),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                        hintText: '请输入昵称',
                                        hintStyle: TextStyle(
                                          color: const Color(0xffa3b4d3),
                                          fontSize: 12.w,
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
                                        if (text.contains(' ')) {
                                          String newText = text.replaceAll(' ', '');
                                          controller.text = newText;
                                          controller.selection = TextSelection.collapsed(offset: newText.length);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                ValueListenableBuilder<int>(
                                    valueListenable: _textLength,
                                    builder: (BuildContext context, int value, Widget? child) {
                                      return Text(
                                        '${controller.text.characters.length}/10',
                                        style: TextStyle(
                                          color: '#333333'.hexColor,
                                          fontSize: 12.w,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    })
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 42.w),
                      ValueListenableBuilder<bool>(
                          valueListenable: _isDisable,
                          builder: (BuildContext context, bool value, Widget? child) {
                            return CustomButton(
                              onPressed: _submitUpdate,
                              disable: value,
                              height: 42.w,
                              title: '确认',
                            );
                          }),
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
    String nickname = controller.text;
    if (nickname.characters.length > 10) {
      ToastUtils.showToast('昵称不能超过10个字');
      return;
    }
    NetRequest().userUpdate(nickname, (data) {
      ToastUtils.showToast('修改成功');
      UserStore.of.getUserInfo();
      Navigator.pop(context);
    });
  }
}
