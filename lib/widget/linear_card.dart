import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

// ignore: must_be_immutable
class LinearCard extends StatefulWidget {
  Widget child;
  EdgeInsetsGeometry? margin;
  EdgeInsetsGeometry? padding;
  LinearCard({super.key, required this.child,this.margin,this.padding});

  @override
  State<LinearCard> createState() => _LinearCardState();
}

class _LinearCardState extends State<LinearCard> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Container(
        margin: widget.margin ?? EdgeInsets.all(0.px),
        padding: widget.padding ?? EdgeInsets.all(0.px),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/commen_bg.png'),
            // fit: BoxFit.cover,
            // // 设置图片拉伸的边缘
            centerSlice: Rect.fromLTRB(30.0, 30.0, 50.0, 50.0),
          ),
        ),
        child: widget.child);
  }
}
