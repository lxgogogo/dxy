import 'package:flutter_quill/flutter_quill.dart';

class AttributeModel {
  final Attribute attribute;
  final String title;
  final String? icon;
  final List<AttributeModel> children;
  bool isSelected;

  AttributeModel(
    this.title,
    this.attribute, {
    this.icon,
    this.isSelected = false,
    this.children = const [],
  });
}
