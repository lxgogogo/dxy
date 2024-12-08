import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlFactoryBuilder extends WidgetFactory {
  final BuildContext context;
  final String content;

  HtmlFactoryBuilder(this.context, {required this.content});

  @override
  void parse(BuildTree meta) {
    final e = meta.element;
    if (e.localName == 'figure' && e.classes.contains('table')) {
      // meta.register(
      //   BuildOp(
      //     onParsed: (BuildTree tree) {
      //       return tree.register(op)
      //     },
      //   ),
      // );
    }
    super.parse(meta);
  }
}





