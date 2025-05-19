import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../flutter_quill.dart';

class QuillEditorAtEmbedBuilder extends EmbedBuilder {
  QuillEditorAtEmbedBuilder();

  @override
  String get key => BlockEmbed.atType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final Map<String, dynamic> map = jsonDecode(embedContext.node.value.data);
    return Text(
      '@${map['nickname']} ',
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xff557BF6),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
