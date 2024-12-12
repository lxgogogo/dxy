import 'dart:io';
import 'dart:ui';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/attribute_model.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:video_player/video_player.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../gen/assets.gen.dart';
import '../../model/board_info.dart';
import '../../model/upload_file.dart';
import '../../utils/common_utils.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import 'widgets/header_style_buttons.dart';
import 'widgets/link_style_button.dart';
import 'widgets/toggle_style_button.dart';

part 'feed_post_controller.dart';

class FeedPostScreen extends StatefulWidget {
  final List<BoardInfo> boardInfoList;

  const FeedPostScreen({super.key, required this.boardInfoList});

  @override
  State<FeedPostScreen> createState() => _FeedPostScreenState();
}

class _FeedPostScreenState extends State<FeedPostScreen> with SingleTickerProviderStateMixin {
  BoardInfo? get currentBord =>
      _prefixIndex != -1 && _prefixIndex < widget.boardInfoList.length ? widget.boardInfoList[_prefixIndex] : null;
  int _prefixIndex = -1;

  final TextEditingController controllerTitle = TextEditingController();

  bool isClickPublish = false;

  final SuperTooltipController _tipController = SuperTooltipController();

  final QuillController quillController = QuillController.basic();
  final FocusNode focusNode = FocusNode();

  final ScrollController scrollController = ScrollController();

  bool showKeyboard = false;
  bool showTextStyle = false;

  final textAttributes = [
    AttributeModel(
      '标题',
      Attribute.header,
      children: [
        AttributeModel('H1 标题', Attribute.h1),
        AttributeModel('H2 标题', Attribute.h2),
        AttributeModel('H3 标题', Attribute.h3),
        AttributeModel('H4 标题', Attribute.h4),
        AttributeModel('H5 标题', Attribute.h5),
      ],
    ),
    AttributeModel('加粗', Attribute.bold),
    AttributeModel('引用', Attribute.blockQuote),
    AttributeModel('有序列表', Attribute.ul),
    AttributeModel('无序列表', Attribute.ol),
  ];
  bool showMore = false;

  final moreAttributes = [
    AttributeModel('添加链接', Attribute.link),
    AttributeModel('添加视频', Attribute.video),
  ];

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: CommonAppBar.arrowBack(
          context,
          actions: [
            GestureDetector(
              onTap: () {
                if (isClickPublish) {
                  return;
                }
                var debouncer = CommonUtils.getDebouncer('publishPosts');
                debouncer.run(() {
                  publishPosts();
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
                  '发帖',
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
          padding: EdgeInsets.only(
            bottom: window.viewPadding.bottom / window.devicePixelRatio,
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
              )),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xffe6e6e6), width: 0.5),
                    ),
                  ),
                  height: 42.5.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.w,
                              color: const Color(0xff2a2a2a),
                            ),
                            maxLength: 30,
                            controller: controllerTitle,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                              hintText: '请输入完整帖子标题（5-31个字）',
                              counterText: '',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.w,
                                color: const Color(0xff2c2c2c).withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              filled: false,
                            )),
                      ),
                      SuperTooltip(
                        showBarrier: true,
                        controller: _tipController,
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
                            itemCount: widget.boardInfoList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (BuildContext context, int index) {
                              final item = widget.boardInfoList[index];
                              return GestureDetector(
                                onTap: () {
                                  _tipController.hideTooltip();
                                  if (_prefixIndex != index) {
                                    _prefixIndex = index;
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  height: 41.5.w,
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.name ?? '',
                                    style: TextStyle(
                                      color: _prefixIndex == index ? const Color(0xff249cfc) : const Color(0xff95a3c4),
                                      fontSize: 14,
                                    ),
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
                            if (widget.boardInfoList.isNotEmpty) {
                              _tipController.showTooltip();
                            }
                          },
                          child: SizedBox(
                            width: 90.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _prefixIndex != -1 && _prefixIndex < widget.boardInfoList.length
                                      ? (widget.boardInfoList[_prefixIndex].name ?? '')
                                      : '选择板块',
                                  style: const TextStyle(
                                    color: Color(0xff2a2a2a),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xff2a2a2a),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: QuillEditor.basic(
                    controller: quillController,
                    focusNode: focusNode,
                    config: QuillEditorConfig(
                      showCursor: true,
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      onTapDown: (_, __) {
                        if (!showKeyboard) {
                          showKeyboard = true;
                          setState(() {
                            showTextStyle = false;
                            showMore = false;
                          });
                        }
                        return false;
                      },
                    ),
                  ),
                ),
                buildBottomToolbar(),
                buildBottomMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.w),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xffe6e6e6)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _openTextStyle,
            child: Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              child: Image.asset(
                Assets.images.inputA.path,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          QuillToolbarImageButton(
            controller: quillController,
            options: QuillToolbarImageButtonOptions(
              imageButtonConfig: QuillToolbarImageConfig(
                onImageInsertCallback: (image, controller) async {
                  String imageUrl = '';
                  final res = await NetRequest().uploadImage(image);
                  if (res != null) {
                    final uploadFile = UploadFile.fromJson(res);
                    imageUrl = uploadFile.url ?? '';
                  }
                  controller
                    ..skipRequestKeyboard = true
                    ..insertImageBlock(imageSource: imageUrl);
                },
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
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: _openMore,
            child: Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              child: Image.asset(
                Assets.images.inputAdd.path,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomMenu() {
    return AnimatedContainer(
      duration: Duration(milliseconds: (showKeyboard && Platform.isAndroid) ? 200 : 340),
      height: _getBottomHeight(),
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (showTextStyle) {
            final itemWidth = (constraints.maxWidth - 12.w) / 2;
            if (textAttributes.first.isSelected) {
              return Wrap(
                spacing: 12.w,
                runSpacing: 12.w,
                children: List.generate(
                  textAttributes.first.children.length,
                  (index) {
                    final e = textAttributes.first.children[index];
                    return QuillToolbarHeaderButton(
                      attributeModel: e,
                      controller: quillController,
                      itemWidth: itemWidth,
                    );
                  },
                ).toList(),
              );
            }
            return Wrap(
              spacing: 12.w,
              runSpacing: 12.w,
              children: List.generate(
                textAttributes.length,
                (index) {
                  final e = textAttributes[index];
                  return QuillToolbarToggleStyleButton(
                    controller: quillController,
                    options: QuillToolbarToggleStyleButtonOptions(
                      childBuilder: (dynamic options, dynamic extraOptions) {
                        QuillToolbarToggleStyleButtonExtraOptions? buttonExtraOptions;
                        if (extraOptions is QuillToolbarToggleStyleButtonExtraOptions) {
                          buttonExtraOptions = extraOptions;
                        }
                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              textAttributes.first.isSelected = true;
                              setState(() {});
                              return;
                            }
                            buttonExtraOptions?.onPressed?.call();
                          },
                          child: Container(
                            width: itemWidth,
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: '#95a3c4'.hexColor.withOpacity(0.1),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: buttonExtraOptions?.isToggled == true ? '#249cfc'.hexColor : '#2a2a2a'.hexColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    attribute: e.attribute,
                  );
                },
              ).toList(),
            );
          } else if (showMore) {
            final itemWidth = (constraints.maxWidth - 12.w * 4) / 5;
            return Wrap(
              spacing: 12.w,
              runSpacing: 12.w,
              children: List.generate(
                moreAttributes.length,
                (index) {
                  final e = moreAttributes[index];
                  if (e.attribute == Attribute.link) {
                    return QuillToolbarLinkStyleButton(
                      controller: quillController,
                      options: QuillToolbarLinkStyleButtonOptions(
                        childBuilder: (dynamic options, dynamic extraOptions) {
                          QuillToolbarLinkStyleButtonExtraOptions? buttonExtraOptions;
                          if (extraOptions is QuillToolbarLinkStyleButtonExtraOptions) {
                            buttonExtraOptions = extraOptions;
                          }
                          return GestureDetector(
                            onTap: buttonExtraOptions?.onPressed,
                            child: Column(
                              children: [
                                Container(
                                  width: itemWidth,
                                  height: itemWidth,
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: '#95a3c4'.hexColor.withOpacity(0.1),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.link),
                                ),
                                SizedBox(height: 4.w),
                                Text(
                                  e.title,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: '#2a2a2a'.hexColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else if (e.attribute == Attribute.video) {
                    return QuillToolbarVideoButton(
                      controller: quillController,
                      options: QuillToolbarVideoButtonOptions(
                        videoConfig: QuillToolbarVideoConfig(
                          onVideoInsertCallback: (video, controller) async {
                            String videoUrl = '';
                            final res = await NetRequest().uploadImage(video);
                            if (res != null) {
                              final uploadFile = UploadFile.fromJson(res);
                              videoUrl = uploadFile.url ?? '';
                            }
                            controller
                              ..skipRequestKeyboard = true
                              ..insertVideoBlock(videoUrl: videoUrl);
                          },
                        ),
                        childBuilder: (dynamic options, dynamic extraOptions) {
                          QuillToolbarVideoButtonExtraOptions? buttonExtraOptions;
                          if (extraOptions is QuillToolbarVideoButtonExtraOptions) {
                            buttonExtraOptions = extraOptions;
                          }
                          return GestureDetector(
                            onTap: buttonExtraOptions?.onPressed,
                            child: Column(
                              children: [
                                Container(
                                  width: itemWidth,
                                  height: itemWidth,
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: '#95a3c4'.hexColor.withOpacity(0.1),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.movie_creation),
                                ),
                                SizedBox(height: 4.w),
                                Text(
                                  e.title,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: '#2a2a2a'.hexColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ).toList(),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  double _getBottomHeight() {
    if (showKeyboard) {
      return MediaQuery.of(context).viewInsets.bottom;
    } else if (showMore || showTextStyle) {
      return 248.0 + MediaQuery.of(context).padding.bottom;
    } else {
      return MediaQuery.of(context).padding.bottom;
    }
  }

  _openMore() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    showKeyboard = false;
    showTextStyle = false;
    showMore = true;
    setState(() {});
  }

  _openTextStyle() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    showKeyboard = false;
    showTextStyle = true;
    textAttributes.first.isSelected = false;
    showMore = false;
    setState(() {});
  }

  void publishPosts() async {
    String title = controllerTitle.text;
    final converter = QuillDeltaToHtmlConverter(
      List.castFrom(quillController.document.toDelta().toJson()),
      ConverterOptions.forEmail(),
    );
    final content = converter.convert();

    if (currentBord == null || currentBord?.id == -1) {
      ToastUtils.showToast('请选择发帖板块');
      return;
    }

    if (title.isEmpty || title.length < 5) {
      ToastUtils.showToast('请输入5-30个字符标题');
      return;
    }

    if (content.isEmpty || content.length < 10) {
      ToastUtils.showToast('帖子内容长度不能小于10个字符');
      return;
    }
    if (isClickPublish) {
      return;
    }
    isClickPublish = true;


    final success = await NetRequest().threadCreate(title, content, currentBord!.id!).whenComplete(() {
      isClickPublish = false;
    });
    if (success) {
      EventBusManager.eventBus.fire(EventBusAction.refreshForumList.eventBusTypeName);

      Get.back();
    }
  }
}
