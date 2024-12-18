import 'dart:convert';
import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/attribute_model.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../gen/assets.gen.dart';
import '../../model/upload_file.dart';
import '../../utils/common_utils.dart';
import '../../utils/net_request.dart';

part 'comment_publish_controller.dart';

class CommentPublishScreen extends GetView<CommentPublishController> {
  const CommentPublishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentPublishController>(
      init: CommentPublishController(),
      builder: (logic) {
        return BackgroundContainer(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: CommonAppBar.arrowBack(
              context,
              actions: [
                GestureDetector(
                  onTap: () {
                    CommonUtils.getDebouncer('publishComment').run(() {
                      controller.submit();
                    });
                  },
                  child: Container(
                    width: 50.5.w,
                    height: 24.w,
                    margin: EdgeInsets.only(right: 10.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: '#249cfc'.hexColor,
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
            body: Container(
              margin: EdgeInsets.only(top: 12.w),
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
                    SizedBox(
                      height: 150.w,
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
                                DefaultTextStyle.of(context).style.copyWith(
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
                    Text(
                      '最多9张图片',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xff2a2a2a).withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 12.w),
                    Expanded(child: _mediaShowView()),
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
          GestureDetector(
            onTap: () async {
              if (!controller.isCanOpenPicker()) {
                ToastUtils.showToast('单个视频或者最多9张图片');
                return;
              }
              controller.openFilePicker();
            },
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
}
