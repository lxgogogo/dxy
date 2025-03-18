import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/at_user/at_user_screen.dart';
import 'package:holdem/page/tag_list/tag_list_screen.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../model/board_info.dart';
import '../../model/upload_file.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';

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
              title: '发帖',
              actions: [
                GestureDetector(
                  onTap: controller.publishPosts,
                  child: Container(
                    height: 28.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    margin: EdgeInsets.only(right: 16.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: controller.isDisable ? '#333333'.hexColor.withOpacity(0.1) : null,
                      gradient: controller.isDisable
                          ? null
                          : LinearGradient(
                              colors: [
                                '#84BCF9'.hexColor,
                                '#557BF6'.hexColor,
                              ],
                            ),
                    ),
                    child: Text(
                      '发布',
                      style: TextStyle(
                        color: controller.isDisable ? '#333333'.hexColor.withOpacity(0.5) : Colors.white,
                        fontSize: 12.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildTitleInput(),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 130.w),
                        padding: EdgeInsets.symmetric(vertical: 16.w),
                        child: QuillEditor.basic(
                          controller: controller.quillController,
                          focusNode: controller.focusNode,
                          config: QuillEditorConfig(
                            showCursor: true,
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                            placeholder: '请输入正文（建议10-2000字）',
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: '#333333'.hexColor,
                                  height: 1.5,
                                ),
                                const HorizontalSpacing(0, 0),
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                null,
                              ),
                              placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: '#333333'.hexColor.withOpacity(0.7),
                                  height: 1.5,
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
                    buildBottomToolbar(context),
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
        border: Border(bottom: BorderSide(color: 'e6e6e6'.hexColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
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
                  fontSize: 16.sp,
                  color: '##333333'.hexColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SuperTooltip(
            showBarrier: true,
            controller: controller.tipController,
            popupDirection: TooltipDirection.down,
            backgroundColor: Colors.transparent,
            hasShadow: false,
            borderColor: Colors.transparent,
            arrowLength: 0,
            arrowTipDistance: 21.25.w,
            bubbleDimensions: EdgeInsets.zero,
            touchThroughAreaShape: ClipAreaShape.rectangle,
            touchThroughAreaCornerRadius: 10,
            minimumOutsideMargin: 0,
            barrierColor: Colors.transparent,
            content: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 300.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.w),
                  ),
                  BoxShadow(
                    color: const Color(0xfffafcff),
                    blurRadius: 1.r,
                    spreadRadius: -1.r,
                    offset: Offset(0, -1.w),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.boardInfoList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  final item = controller.boardInfoList[index];
                  return GestureDetector(
                    onTap: () {
                      controller.tipController.hideTooltip();
                      if (controller.prefixIndex != index) {
                        controller.prefixIndex = index;
                        controller.safeUpdate();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
                      alignment: Alignment.center,
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          color: controller.prefixIndex == index ? const Color(0xff249cfc) : '#333333'.hexColor,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  color: '#333333'.hexColor.withOpacity(0.1),
                  height: 1.w,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (controller.boardInfoList.isNotEmpty) {
                  controller.tipController.showTooltip();
                }
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
                    Icon(Icons.arrow_drop_down, color: '#2a2a2a'.hexColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomToolbar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      onTap: buttonExtraOptions?.onPressed,
                      child: Container(
                          width: 75.w,
                          height: 75.w,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333333).withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 26.w,
                            color: '#333333'.hexColor.withOpacity(0.5),
                          )),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 12.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (controller.tagList.length < controller.tagMaxLength)
                    GestureDetector(
                      onTap: controller.toAddTag,
                      child: Container(
                        height: 26.w,
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: '#557BF6'.hexColor),
                        ),
                        child: Text(
                          '#话题${controller.tagList.isNotEmpty ? '（${controller.tagList.length}/${controller.tagMaxLength}）' : ''}',
                          style: TextStyle(
                            fontSize: 10.sp,
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
                      height: 26.w,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: '#557BF6'.hexColor),
                      ),
                      child: Text(
                        '@ 用户',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: '#557BF6'.hexColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          buildTagList(controller),
        ],
      ),
    );
  }

  Widget buildTagList(FeedPostController controller) {
    return Container(
      padding: EdgeInsets.only(bottom: 16.w),
      margin: EdgeInsets.only(right: 16.w, top: 16.w),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: '#333333'.hexColor.withOpacity(0.1), width: 0.5.w),
      )),
      child: Wrap(
        spacing: 8.0, // 添加水平间距
        runSpacing: 4.0,
        children: [
          ...List.generate(
            controller.tagList.length,
            (index) {
              final tag = controller.tagList[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                    decoration: ShapeDecoration(
                      color: '#557BF6'.hexColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag.name ?? '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: '#557BF6'.hexColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        GestureDetector(
                          onTap: () => controller.removeTag(index),
                          child: Icon(
                            Icons.clear,
                            size: 12.w,
                            color: '#557BF6'.hexColor,
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
    );
  }
}
