import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/attribute_model.dart';

typedef QuillToolbarSelectHeaderStyleBaseButtons = QuillToolbarBaseButton<QuillToolbarSelectHeaderStyleButtonsOptions,
    QuillToolbarSelectHeaderStyleButtonsExtraOptions>;

typedef QuillToolbarSelectHeaderStyleBaseButtonsState<W extends QuillToolbarSelectHeaderStyleBaseButtons>
    = QuillToolbarCommonButtonState<W, QuillToolbarSelectHeaderStyleButtonsOptions,
        QuillToolbarSelectHeaderStyleButtonsExtraOptions>;

class QuillToolbarHeaderButton extends QuillToolbarSelectHeaderStyleBaseButtons {
  const QuillToolbarHeaderButton({
    required super.controller,
    required this.attributeModel,
    required this.itemWidth,
    super.options = const QuillToolbarSelectHeaderStyleButtonsOptions(),
    super.baseOptions,
    super.key,
  });

  final AttributeModel attributeModel;
  final double itemWidth;

  @override
  QuillToolbarHeaderButtonState createState() => QuillToolbarHeaderButtonState();
}

class QuillToolbarHeaderButtonState extends QuillToolbarSelectHeaderStyleBaseButtonsState<QuillToolbarHeaderButton> {
  Attribute? _selectedAttribute;

  @override
  String get defaultTooltip => widget.attributeModel.title;

  @override
  IconData get defaultIconData => Icons.question_mark_outlined;

  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
    controller.addListener(_didChangeEditingValue);
  }

  Axis get axis {
    return options.axis ?? Axis.horizontal;
  }

  void _sharedOnPressed() {
    final attribute0 = _selectedAttribute == widget.attributeModel.attribute ? Attribute.header : widget.attributeModel.attribute;
    controller..skipRequestKeyboard = true..formatSelection(attribute0);
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = _selectedAttribute == widget.attributeModel.attribute;
    return GestureDetector(
      onTap: () => _sharedOnPressed(),
      child: Container(
        width: widget.itemWidth,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: '#95a3c4'.hexColor.withOpacity(0.1),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.attributeModel.title,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? '#249cfc'.hexColor : '#2a2a2a'.hexColor,
          ),
        ),
      ),
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
  }

  Attribute<dynamic> _getHeaderValue() {
    final attr = controller.toolbarButtonToggler[Attribute.header.key];
    if (attr != null) {
      // checkbox tapping causes controller.selection to go to offset 0
      controller.toolbarButtonToggler.remove(Attribute.header.key);
      return attr;
    }
    return _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
  }

  @override
  void didUpdateWidget(covariant QuillToolbarHeaderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      controller.addListener(_didChangeEditingValue);
      _selectedAttribute = _getHeaderValue();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }
}
