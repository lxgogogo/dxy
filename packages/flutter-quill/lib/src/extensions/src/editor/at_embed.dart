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
    return Text(
      '@${embedContext.node.value.data} ',
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xff249cfc),
      ),
    );
  }
}
