import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../utils/toast_utils.dart';

part 'comment_input_controller.dart';

class CommentInputScreen extends GetView<CommentInputController> {
  final String relType; //// 评论对象类型
  final int relId; //// 评论对象id

  const CommentInputScreen({super.key, required this.relType, required this.relId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentInputController>(
      init: CommentInputController(relType, relId),
      builder: (logic) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.w).copyWith(bottom: ScreenUtil().bottomBarHeight),
          decoration: BoxDecoration(
            color: const Color(0xffF2F8FD),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 51.w,
                      decoration: BoxDecoration(
                        color: '#95a3c4'.hexColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: DetectableTextField(
                        maxLines: null,
                        controller: controller.textInput,
                        style: TextStyle(
                          color: const Color(0xff3b5078),
                          fontSize: 14.px,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
                          hintText: '说点什么…',
                          hintStyle: TextStyle(
                            color: const Color(0xffa3b4d3),
                            fontSize: 14.sp,
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
                        onChanged: controller.onChanged,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: controller.submit,
                    child: Container(
                      width: 50.5.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: '#249cfc'.hexColor.withOpacity(controller.canSend ? 1 : 0.5),
                      ),
                      child: Text(
                        '发布',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              GestureDetector(
                onTap: controller.toAtUser,
                child: Text(
                  '@',
                  style: TextStyle(
                    color: '#787b86'.hexColor,
                    fontSize: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
