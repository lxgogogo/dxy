import 'package:flutter/material.dart';

class WebFitPage extends StatefulWidget {
  Widget child;
  WebFitPage({super.key, required this.child});

  @override
  State<WebFitPage> createState() => _WebFitPageState();
}

class _WebFitPageState extends State<WebFitPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = 960.0; // 设置最大宽度
      final horizontalPadding = constraints.maxWidth > maxWidth?(constraints.maxWidth - maxWidth) / 2:0.0;

      return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: widget.child);
    });
  }
}
