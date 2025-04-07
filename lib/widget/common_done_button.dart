
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

// ignore: must_be_immutable
class CommonDoneButton extends StatefulWidget {
  final String title;
  final double? width;
  final double height;
  final Function signUpOnTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double radus;
  final double fontSize;
  final FontWeight fontWeight;
  bool disable;
  List<Color>? colors;
  Color? normalColor;
  Color? selectBgColor;
  Color disableColor;

  CommonDoneButton(
      {super.key,
        required this.title,
        required this.signUpOnTap,
        this.width,
        this.height = 24,
        this.disable = true,
        this.fontWeight = FontWeight.w600,
        this.radus = 12,
        this.fontSize = 12,
        this.disableColor = Colors.white,
        this.margin,
        this.padding,
        this.colors,
        this.normalColor,
        this.selectBgColor});

  @override
  createState() => _OlCommonSureButtonWidgetState();
}

class _OlCommonSureButtonWidgetState extends State<CommonDoneButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  build(BuildContext context) {
    widget.colors ??= [
      '#557BF6'.hexColor,
      '#84BCF9'.hexColor
    ];
    widget.normalColor ??= '#333333'.hexColor.withOpacity(0.5);
    widget.selectBgColor ??= '#333333'.hexColor.withOpacity(0.1);
    EdgeInsets padding = widget.padding != null ? widget.padding! : EdgeInsets.only(left: 8.w, right: 8.w);

    return GestureDetector(
      onTap: () {
        if (widget.disable) {
          widget.signUpOnTap();
        }
      },
      child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(widget.radus)),
              color: widget.disable ? Colors.white : widget.selectBgColor,
              gradient: widget.disable
                  ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: widget.colors!,
                  stops: const [0, 1])
                  : null),
          alignment: Alignment.center,
          child: Text(widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontWeight: widget.fontWeight,
                fontSize: widget.fontSize,
                color: widget.disable ? widget.disableColor : widget.normalColor!,
              ))),
    );
  }
}
