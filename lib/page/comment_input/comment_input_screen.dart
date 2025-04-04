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
            color:Colors.white,
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
                      padding: EdgeInsets.symmetric( vertical: 8.w),

                      child: QuillEditor.basic(
                        controller: controller.quillController,
                        config: QuillEditorConfig(
                          showCursor: true,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          placeholder: '说点什么吧...',
                          customStyles:DefaultStyles.getInstance(context).merge(DefaultStyles(placeHolder: DefaultTextBlockStyle(
                              TextStyle(
                                fontSize: 14.sp,
                                color: '#333333'.hexColor.withOpacity(0.7),
                              ),
                              HorizontalSpacing.zero,
                              VerticalSpacing.zero,
                              VerticalSpacing.zero,
                              null))),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  GestureDetector(
                    onTap: controller.submit,
                    child: Container(
                      width: 50.5.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      child: Text(
                        '发布',
                        style: TextStyle(
                          color: '#557BF6'.hexColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
