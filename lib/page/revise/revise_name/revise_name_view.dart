import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/input_limit_helper.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'revise_name_controller.dart';

class ReviseNamePage extends StatefulWidget {
  const ReviseNamePage({Key? key}) : super(key: key);

  @override
  State<ReviseNamePage> createState() => _ReviseNamePageState();
}

class _ReviseNamePageState extends State<ReviseNamePage> {
  final ReviseNameController controller = Get.put(ReviseNameController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
            appBar: CommonAppBar.arrowBack(context, title: '修改昵称', actions: [
              GestureDetector(
                onTap: () {
                  controller.reviseOnTap(context);
                },
                child: Container(
                  padding: EdgeInsets.only(right: 16.w),
                  color: Colors.transparent,
                  child: Text(
                    '完成',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.color_557BF6),
                  ),
                ),
              )
            ]),
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.w),
                  Text(
                    '新昵称',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.c333333
                    ),
                  ),
                  SizedBox(height: 12.w),
                  Container(
                      height: 40.w,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: ColorStyle.c333333.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: TextField(
                            controller: controller.textEditingController,
                            style: TextStyle(
                              color: ColorStyle.c333333,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            inputFormatters: <TextInputFormatter>[
                              CustomizedLengthTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
                              hintText: '昵称最多十个字',
                              hintStyle: TextStyle(
                                color: AppTheme.color_999999,
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
                                controller.textEditingController.text = newText;
                                controller.textEditingController.selection = TextSelection.collapsed(offset: newText.length);
                              }
                            },
                          ))
                        ],
                      )),
                ],
              ),
            ))
    );
  }

  @override
  void dispose() {
    Get.delete<ReviseNameController>();
    super.dispose();
  }
}