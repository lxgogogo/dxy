import 'dart:convert';

import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

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
                      constraints: BoxConstraints(minHeight: 56.w, maxHeight: 120.w),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                      decoration: BoxDecoration(
                        color: '#95a3c4'.hexColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: QuillEditor.basic(
                        controller: controller.quillController,
                        config: QuillEditorConfig(
                          showCursor: true,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                        ),
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
                        color: '#249cfc'.hexColor/*.withOpacity(controller.canSend ? 1 : 0.5)*/,
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
              GestureDetector(
                onTap: () async {
                  final result = await Get.toNamed(Routes.atUser);
                  if (result != null) {
                    controller.quillController.insertAtBlock(data: json.encode(result));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text(
                    '@',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
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
