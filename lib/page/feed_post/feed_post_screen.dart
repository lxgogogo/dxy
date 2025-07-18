import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/at_user/at_user_screen.dart';
import 'package:holdem/page/tag_list/tag_list_screen.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../gen/assets.gen.dart';
import '../../model/board_info.dart';
import '../../model/upload_file.dart';
import '../../utils/net_request.dart';
import '../../widget/common_operations_sheet.dart';

part 'feed_post_controller.dart';

class FeedPostScreen extends GetView<FeedPostController> {
  final List<BoardInfo> boardInfoList;

  const FeedPostScreen({super.key, required this.boardInfoList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedPostController>(
      init: FeedPostController(),
      builder: (_) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: CommonAppBar.arrowBack(
              context,
              title: '发布帖子',
              actions: [
                GestureDetector(
                  onTap: controller.publishPosts,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignment: Alignment.center,
                    child: Text(
                      '发布',
                      style: TextStyle(
                        color: controller.isDisable ? '#999999'.hexColor : '#557BF6'.hexColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              margin: EdgeInsets.only(top: 12.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildTitleInput(),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 130.w),
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        child: QuillEditor.basic(
                          controller: controller.quillController,
                          focusNode: controller.focusNode,
                          config: QuillEditorConfig(
                            showCursor: true,
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                            placeholder: '添加正文（建议10-2000字）',
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: '#333333'.hexColor,
                                ),
                                const HorizontalSpacing(0, 0),
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                null,
                              ),
                              placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: '#999999'.hexColor,
                                ),
                                const HorizontalSpacing(0, 0),
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    buildBottomToolbar(context)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: '#333333'.hexColor.withOpacity(0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: '#333333'.hexColor,
              ),
              maxLength: 31,
              controller: controller.titleInput,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: false,
                hintText: '添加标题(最多31字)',
                counterText: '',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: '#999999'.hexColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showCommonOperationsSheet(
                items: controller.boardInfoList.map((e) => e.name ?? '').toList(),
                onSelectItem: (int index) {
                  if (controller.prefixIndex != index) {
                    controller.prefixIndex = index;
                    controller.safeUpdate();
                  }
                },
              );
            },
            child: SizedBox(
              width: 90.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      controller.prefixIndex != -1 && controller.prefixIndex < controller.boardInfoList.length
                          ? (controller.boardInfoList[controller.prefixIndex].name ?? '')
                          : '选择板块',
                      style: TextStyle(
                        color: '#333333'.hexColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    Assets.svg.arrowDown,
                    width: 12.w,
                    height: 12.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomToolbar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            QuillToolbarImageButton(
              controller: controller.quillController,
              options: QuillToolbarImageButtonOptions(
                imageButtonConfig: QuillToolbarImageConfig(
                  onImageInsertCallback: controller.onImageInsertCallback,
                ),
                childBuilder: (dynamic options, dynamic extraOptions) {
                  QuillToolbarImageButtonExtraOptions? buttonExtraOptions;
                  if (extraOptions is QuillToolbarImageButtonExtraOptions) {
                    buttonExtraOptions = extraOptions;
                  }
                  return GestureDetector(
                    onTap: () {
                      int count = 0;
                      final operations = controller.quillController.document.toDelta().toJson();
                      for (final data in operations) {
                        if (data.containsKey('insert')) {
                          if (data['insert'] is Map) {
                            if (data['insert'].containsKey('image')) {
                              count++;
                            }
                          }
                        }
                      }
                      if (count == 9) {
                        DialogUtil.showToast('最多只可上传9张图片');
                        return;
                      }
                      buttonExtraOptions?.onPressed?.call();
                    },
                    child: Container(
                      height: 28.w,
                      margin: EdgeInsets.only(right: 12.w),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: '#557BF6'.hexColor),
                      ),
                      child: Text(
                        '+ 添加图片',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: '#557BF6'.hexColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (controller.tagList.length < controller.tagMaxLength)
              GestureDetector(
                onTap: controller.toAddTag,
                child: Container(
                  height: 28.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: '#557BF6'.hexColor),
                  ),
                  child: Text(
                    '# 话题${controller.tagList.isNotEmpty ? '（${controller.tagList.length}/${controller.tagMaxLength}）' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: '#557BF6'.hexColor,
                    ),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () async {
                final result = await await Get.bottomSheet(
                  const AtUserScreen(),
                  isScrollControlled: true,
                );
                if (result != null) {
                  controller.quillController.insertAtBlock(data: json.encode(result));
                }
              },
              child: Container(
                height: 28.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: '#557BF6'.hexColor),
                ),
                child: Text(
                  '@ 用户',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: '#557BF6'.hexColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (controller.tagList.isNotEmpty) buildTagList(controller) else SizedBox(height: 12.w),
      ],
    );
  }

  Widget buildTagList(FeedPostController controller) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(right: 16.w, top: 16.w),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: '#000000'.hexColor.withOpacity(0.05), width: 0.5.w),
            )),
        child: Wrap(
          spacing: 12.w,
          runSpacing: 8.w,
          children: [
            ...List.generate(
              controller.tagList.length,
              (index) {
                final tag = controller.tagList[index];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 28.w,
                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                      decoration: ShapeDecoration(
                        color: '#557BF6'.hexColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag.name ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: '#557BF6'.hexColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          GestureDetector(
                            onTap: () => controller.removeTag(index),
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: SvgPicture.asset(
                                Assets.svg.iconClose,
                                width: 10.w,
                                height: 10.w,
                                color: '#557BF6'.hexColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
