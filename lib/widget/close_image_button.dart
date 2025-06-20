import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/gen/assets.gen.dart';

class CloseImageButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CloseImageButton({
    super.key,
    this.onTap,
    this.width = 12,
    this.height = 12,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        padding: padding ?? const EdgeInsets.all(12).copyWith(left: 20, bottom: 20),
        child: SvgPicture.asset(
          Assets.svg.iconClose,
          width: width,
          height: height,
          color: color,
        ),
      ),
    );
  }
}
