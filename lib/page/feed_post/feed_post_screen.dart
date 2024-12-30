import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/tag_list/tag_list_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../gen/assets.gen.dart';
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
        return BackgroundContainer(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            appBar: CommonAppBar.arrowBack(
              context,
              actions: [
                GestureDetector(
                  onTap: controller.publishPosts,
                  child: Container(
                    height: 24.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    margin: EdgeInsets.only(right: 10.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: '#249cfc'.hexColor,
                    ),
                    child: Text(
                      '发帖',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              margin: EdgeInsets.only(top: 12.w),
              padding: EdgeInsets.only(
                bottom: ScreenUtil().bottomBarHeight,
              ),
              decoration: const BoxDecoration(
                color: Color(0xfff2f9ff),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF6FBFF),
                    Color(0xFFE8F3FF),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildTitleInput(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.w),
                        child: QuillEditor.basic(
                          controller: controller.quillController,
                          focusNode: controller.focusNode,
                          config: QuillEditorConfig(
                            showCursor: true,
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                            placeholder: '请输入正文（建议10-2000字）',
                            customStyles: DefaultStyles(
                              placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: '#2c2c2c'.hexColor.withOpacity(0.5),
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
                    if (controller.focusNode.hasFocus) buildBottomToolbar(context) else buildTagList(context)
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
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: '#2a2a2a'.hexColor,
              ),
              maxLength: 30,
              controller: controller.titleInput,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: false,
                hintText: '请输入完整帖子标题（5-31个字）',
                counterText: '',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: '#2c2c2c'.hexColor.withOpacity(0.5),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
                      height: 41.5.w,
                      alignment: Alignment.center,
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          color: controller.prefixIndex == index ? const Color(0xff249cfc) : const Color(0xff95a3c4),
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => Container(
                  color: const Color(0xffe7f0fa),
                  height: 0.5,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (controller.boardInfoList.isNotEmpty) {
                  controller.tipController.showTooltip();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.prefixIndex != -1 && controller.prefixIndex < controller.boardInfoList.length
                        ? (controller.boardInfoList[controller.prefixIndex].name ?? '')
                        : '选择板块',
                    style: TextStyle(
                      color: '#2a2a2a'.hexColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: '#2a2a2a'.hexColor),
                ],
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
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xffe6e6e6)),
        ),
      ),
      child: Row(
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
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    child: Image.asset(
                      Assets.images.inputImage.path,
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(Routes.atUser);
              if (result != null) {
                controller.quillController.insertAtBlock(data: json.encode(result));
              }
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              child: Text(
                '@',
                style: TextStyle(
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTagList(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.w),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.generate(
              controller.tagList.length,
              (index) {
                final tag = controller.tagList[index];
                return GestureDetector(
                  onTap: () => controller.removeTag(index),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.w),
                        margin: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: '#249CFC'.hexColor),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tag.name ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: '#249CFC'.hexColor,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0.w,
                        top: 0.w,
                        child: GestureDetector(
                          onTap: () => controller.removeTag(index),
                          child: Assets.images.closeBlack.image(
                            width: 10.w,
                            height: 10.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (controller.tagList.length < controller.tagMaxLength)
              GestureDetector(
                onTap: controller.toAddTag,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.w),
                  margin: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: '#249CFC'.hexColor),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ 插入话题（${controller.tagList.length}/${controller.tagMaxLength}）',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: '#249CFC'.hexColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
