import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/common_done_button.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/color_style_util.dart';
import '../../../widget/common_app_bar.dart';
import 'creat_collect_group_controller.dart';

class CreatCollectGroupPage extends StatefulWidget {
  const CreatCollectGroupPage({Key? key}) : super(key: key);

  @override
  State<CreatCollectGroupPage> createState() => _CreatCollectGroupPageState();
}

class _CreatCollectGroupPageState extends State<CreatCollectGroupPage> {
  final CreatCollectGroupController controller =
      Get.put(CreatCollectGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar.arrowBack(context,
            title: controller.isCreate ? '新建收藏分类' : '修改收藏分类',
            actions: [
              Obx(() => CommonDoneButton(
                  title: controller.isCreate ? '下一步' : '完成',
                  margin: EdgeInsets.only(right: 12.w),
                  disable: controller.enable.value,
                  signUpOnTap: controller.signUpOnTap))
            ]),
        body: Container(
          margin: EdgeInsets.only(top: 20.w, left: 12.w, right: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分类命名',
                style: TextStyle(
                    fontSize: 14.w,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(
                height: 40.w,
                child: field(controller.textController, '分类名称最多十个字',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ], onChanged: (value) {
                  controller.enable.value =
                      value.isNotEmpty && value.length <= 10 ? true : false;
                }),
              )
            ],
          ),
        ));
  }

  TextField field(TextEditingController textController, String hintText,
      {bool obscureText = false,
      Widget? prefix,
      bool isNumber = false,
      bool enabled = true,
      FocusNode? focusNode,
      ValueChanged<String>? onChanged,
      VoidCallback? onEditingComplete,
      List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: textController,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.w,
      ),
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        // labelText: "手机号",
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
        // 去掉下滑线
        counterText: '',
        // 去除输入框底部的字符计数
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 12.w, color: ColorStyle.c333333),
        // prefix: prefix,
        prefixIcon: prefix,
      ),
      obscureText: obscureText,
      inputFormatters: inputFormatters,
    );
  }

  @override
  void dispose() {
    Get.delete<CreatCollectGroupController>();
    super.dispose();
  }
}
