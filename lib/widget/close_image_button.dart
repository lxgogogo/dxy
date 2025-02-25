import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/size_fit.dart';

class CloseImageButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  const CloseImageButton({super.key, this.onPressed,this.width,this.height,this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,padding: EdgeInsets.zero,

      icon: SvgPicture.asset('assets/svg/icon_close.svg',width:width?? 28.px,height: height??30.px,color: color??Colors.black,),
    );
  }
}
