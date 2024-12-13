import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../flutter_quill.dart';

class QuillEditorDividerEmbedBuilder extends EmbedBuilder {
  QuillEditorDividerEmbedBuilder();

  @override
  String get key => BlockEmbed.dividerType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Divider(
      thickness: 1,
      color: Colors.grey[300],
    );
  }
}
