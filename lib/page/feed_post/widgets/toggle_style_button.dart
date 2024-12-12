import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/attribute_model.dart';

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize,
  QuillIconTheme? iconTheme,
]);

class QuillToolbarToggleButton extends QuillToolbarToggleStyleBaseButton {
  const QuillToolbarToggleButton({
    required super.controller,
    required this.attributeModel,
    required this.itemWidth,
    super.options = const QuillToolbarToggleStyleButtonOptions(),
    super.baseOptions,
    super.key,
  });

  final AttributeModel attributeModel;
  final double itemWidth;

  @override
  QuillToolbarToggleButtonState createState() =>
      QuillToolbarToggleButtonState();
}

class QuillToolbarToggleButtonState
    extends QuillToolbarToggleStyleBaseButtonState<
        QuillToolbarToggleButton> {
  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  bool get currentStateValue => _getIsToggled(_selectionStyle.attributes);

  (String, IconData) get _defaultTooltipAndIconData {
    switch (widget.attributeModel.attribute.key) {
      case 'bold':
        return (context.loc.bold, Icons.format_bold);
      case 'script':
        if (widget.attributeModel.attribute.value == ScriptAttributes.sub.value) {
          return (context.loc.subscript, Icons.subscript);
        }
        return (context.loc.superscript, Icons.superscript);
      case 'italic':
        return (context.loc.italic, Icons.format_italic);
      case 'small':
        return (context.loc.small, Icons.format_size);
      case 'underline':
        return (context.loc.underline, Icons.format_underline);
      case 'strike':
        return (context.loc.strikeThrough, Icons.format_strikethrough);
      case 'code':
        return (context.loc.inlineCode, Icons.code);
      case 'direction':
        return (context.loc.textDirection, Icons.format_textdirection_r_to_l);
      case 'list':
        if (widget.attributeModel.attribute.value == 'bullet') {
          return (context.loc.bulletList, Icons.format_list_bulleted);
        }
        return (context.loc.numberedList, Icons.format_list_numbered);
      case 'code-block':
        return (context.loc.codeBlock, Icons.code);
      case 'blockquote':
        return (context.loc.quote, Icons.format_quote);
      case 'align':
        return switch (widget.attributeModel.attribute.value) {
          'left' => (context.loc.alignLeft, Icons.format_align_left),
          'right' => (context.loc.alignRight, Icons.format_align_right),
          'center' => (context.loc.alignCenter, Icons.format_align_center),
          'justify' => (context.loc.alignJustify, Icons.format_align_justify),
          Object() => throw ArgumentError(widget.attributeModel.attribute.value),
          null => (context.loc.alignCenter, Icons.format_align_center),
        };
      default:
        throw ArgumentError(
          'Could not find the default tooltip for '
          '${widget.attributeModel.attribute.toString()}',
        );
    }
  }

  @override
  String get defaultTooltip => _defaultTooltipAndIconData.$1;

  @override
  IconData get defaultIconData => _defaultTooltipAndIconData.$2;

  void _onPressed() {
    _toggleAttribute();
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Container(
        width: widget.itemWidth,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: '#95a3c4'.hexColor.withOpacity(0.1),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          defaultTooltip,
          style: TextStyle(
            fontSize: 14.sp,
            color: currentValue ? '#249cfc'.hexColor : '#2a2a2a'.hexColor,
          ),
        ),
      ),
    );
    return UtilityWidgets.maybeTooltip(
      message: tooltip,
      child: defaultToggleStyleButtonBuilder(
        context,
        widget.attributeModel.attribute,
        iconData,
        currentValue,
        _toggleAttribute,
        afterButtonPressed,
        iconSize,
        iconButtonFactor,
        iconTheme,
      ),
    );
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    if (widget.attributeModel.attribute.key == Attribute.list.key ||
        widget.attributeModel.attribute.key == Attribute.header.key ||
        widget.attributeModel.attribute.key == Attribute.script.key ||
        widget.attributeModel.attribute.key == Attribute.align.key) {
      final attribute = attrs[widget.attributeModel.attribute.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == widget.attributeModel.attribute.value;
    }
    return attrs.containsKey(widget.attributeModel.attribute.key);
  }

  void _toggleAttribute() {
    controller
      // ..skipRequestKeyboard = true
      ..skipRequestKeyboard = !widget.attributeModel.attribute.isInline
      ..formatSelection(
        currentValue
            ? Attribute.clone(widget.attributeModel.attribute, null)
            : widget.attributeModel.attribute,
      );
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize = kDefaultIconSize,
  double iconButtonFactor = kDefaultIconButtonFactor,
  QuillIconTheme? iconTheme,
]) {
  final isEnabled = onPressed != null;
  return QuillToolbarIconButton(
    icon: Icon(
      icon,
      size: iconSize * iconButtonFactor,
    ),
    isSelected: isEnabled ? isToggled == true : false,
    onPressed: onPressed,
    afterPressed: afterPressed,
    iconTheme: iconTheme,
  );
}
