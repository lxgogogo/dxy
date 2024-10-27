import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/utils/size_fit.dart';

class CloseImageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CloseImageButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset('assets/svg/icon_close.svg',width: 28.px,height: 30.px),
    );
  }
}
