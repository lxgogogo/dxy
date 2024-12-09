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
                    var debouncer = CommonUtils.getDebouncer('publishComment');
                    debouncer.run(() {
                      controller.publishPosts();
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
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 150.w,
                          child: DetectableTextField(
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xff2a2a2a),
                              ),
                              controller: controller._controller,
                              onChanged: (text) {
                                // _handleTextChange();
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2000),
                              ],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.5.w),
                                hintText: '请输入正文（建议10-2000字）',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff2a2a2a).withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                filled: false,
                              )),
                        ),
                        Text(
                          '最多9张图片',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xff2a2a2a).withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 12.w),
                        _mediaShowView(),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                    child: bottomView(),
                  )
                ],
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

  Widget bottomView() {
    return Container(
      height: 41.5.w,
      color: const Color(0xFFE8F3FF),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xffe6e6e6))),
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
              child: Icon(
                Icons.image_outlined,
                color: '#787b86'.hexColor,
              ),
            ),
            SizedBox(width: 24.w),
            GestureDetector(
              onTap: controller.toAtUser,
              child: Text(
                '@',
                style: TextStyle(
                  color: '#787b86'.hexColor,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
