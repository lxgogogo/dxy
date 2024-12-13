import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlFactoryBuilder extends WidgetFactory {
  final BuildContext context;
  final String content;

  HtmlFactoryBuilder(this.context, {required this.content});

  @override
  void parse(BuildTree meta) {
    final e = meta.element;
    if (meta.element.localName == 'td' || meta.element.localName == 'th') {
      meta.register(
        BuildOp(
          onRenderedBlock: (BuildTree tree, Widget block) {

          }
        ),
      );
    }
    super.parse(meta);
  }
}
