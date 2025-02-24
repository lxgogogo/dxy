import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/utils/size_fit.dart';

class CloseImageButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  const CloseImageButton({super.key, this.onPressed,this.width,this.height});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,padding: EdgeInsets.zero,

      icon: SvgPicture.asset('assets/svg/icon_close.svg',width:width?? 28.px,height: height??30.px),
    );
  }
}
