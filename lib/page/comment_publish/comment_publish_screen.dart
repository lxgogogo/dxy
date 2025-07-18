import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../gen/assets.gen.dart';
import '../../model/upload_file.dart';
import '../../utils/common_utils.dart';
import '../../utils/html_parse_util.dart';
import '../../utils/net_request.dart';
import '../../utils/track_utils.dart';

part 'comment_publish_controller.dart';

class CommentPublishScreen extends GetView<CommentPublishController> {
  const CommentPublishScreen({
    super.key,
    required this.relType,
    required this.relId,
    required this.sourceType,
  });

  final String relType;
  final int relId;
  final SourceType sourceType;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentPublishController>(
      init: CommentPublishController(relType, relId, sourceType),
      builder: (logic) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.w),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(minHeight: 150.w),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.w),
                      child: QuillEditor.basic(
                        controller: controller.quillController,
                        focusNode: controller.focusNode,
                        config: QuillEditorConfig(
                          showCursor: true,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          placeholder: '说点什么吧...',
                          customStyles: DefaultStyles.getInstance(context).merge(DefaultStyles(
                              placeHolder: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 14.sp,
                                    color: '#999999'.hexColor,
                                  ),
                                  HorizontalSpacing.zero,
                                  VerticalSpacing.zero,
                                  VerticalSpacing.zero,
                                  null))),
                        ),
                      ),
                    ),
                  ),
                ),
                imageGallery(),
                buildBottomToolbar(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget imageGallery() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Row(
          children: controller.imageData
              .map(
                (filePath) => Row(
                  children: [
                    SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: Stack(
                        key: ValueKey(filePath),
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              File(filePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => controller.deleteMediaItem(filePath),
                              behavior: HitTestBehavior.translucent,
                              child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: SvgPicture.asset(
                                  Assets.svg.closeBlack,
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8.w,
                    )
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _mediaShowView() {
    return ReorderableGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      dragEnabled: false,
      onReorder: (int oldIndex, int newIndex) {},
      footer: [
        if (controller.imageData.length < 9)
          GestureDetector(
            onTap: controller.openFilePicker,
            child: Image.asset(
              'assets/images/image_add.png',
            ),
          ),
      ],
      children: controller.imageData
          .map(
            (filePath) => Stack(
              key: ValueKey(filePath),
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(filePath),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => controller.deleteMediaItem(filePath),
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Image.asset(
                        'assets/images/close_black.png',
                        width: 12.w,
                        height: 12.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget buildBottomToolbar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                if (!controller.isCanOpenPicker()) {
                  DialogUtil.showToast('最多只可上传9张图片');
                  return;
                }
                controller.openFilePicker();
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: 16.w,
                ),
                child: SvgPicture.asset(
                  Assets.svg.inputImage,
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final result = await Get.toNamed(Routes.atUser);
                if (result != null) {
                  controller.quillController.insertAtBlock(data: json.encode(result));
                }
              },
              child: SvgPicture.asset(
                Assets.svg.inputAt,
                width: 20.w,
                height: 20.w,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                CommonUtils.getDebouncer('publishComment').run(() {
                  controller.submit();
                });
              },
              child: Text(
                '发布',
                style: TextStyle(
                  color: '#557BF6'.hexColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
