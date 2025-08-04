import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/app_theme.dart';

class TextInsideCupertinoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String activeText;
  final String inactiveText;
  final TextStyle textStyle;

  const TextInsideCupertinoSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeText = 'ON',
    this.inactiveText = 'OFF',
    this.textStyle = const TextStyle(
      fontSize: 10,
      color: Colors.red,
    ),
  }) : super(key: key);

  @override
  _TextInsideCupertinoSwitchState createState() => _TextInsideCupertinoSwitchState();
}

class _TextInsideCupertinoSwitchState extends State<TextInsideCupertinoSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.value;
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          setState(() => _value = !_value);
          widget.onChanged!(_value);
        }
      },
      child: SizedBox(
        width: 48.w,
        height: 22.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 开关背景
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 48.w,
              height: 22.w,
              alignment:  _value ? Alignment.centerLeft : Alignment.centerRight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11.w),
                color: _value
                    ? '#34C759'.hexColor
                    : CupertinoColors.tertiarySystemFill,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: _value ? 8.w : 0.w, right: !_value ? 8.w : 0.w),
                child: Text(
                  _value ? widget.activeText : widget.inactiveText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _value ? Colors.white : AppTheme.color_666666
                  )
                ),
              )
            ),
            // 可滑动按钮（包含文字）
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 4.w),
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8.w),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.5),
                      blurRadius: 1,
                      spreadRadius: 0.5,
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}