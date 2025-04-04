import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../gen/assets.gen.dart';

class ScanAreaClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  ScanAreaClipper({required this.width, required this.height});

  @override
  Path getClip(Size size) {
    return getPath(size);
  }

  @override
  bool shouldReclip(covariant ScanAreaClipper oldClipper) {
    return oldClipper.width != width || oldClipper.height != height;
  }

  Path getPath(Size size) {
    final double left = (size.width - width) / 2;
    final double top = (size.height - height) / 2;
    final double right = left + width;
    final double bottom = top + height;
    const double cutSize = 16;

    Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    Path scanPath = Path();

    // 左上
    scanPath.moveTo(left + cutSize, top);
    scanPath.lineTo(right - cutSize, top);
    scanPath.arcToPoint(
      Offset(right, top + cutSize),
      radius: const Radius.circular(cutSize),
      clockwise: true,
    );

    // 右上
    scanPath.lineTo(right, bottom - cutSize);
    scanPath.arcToPoint(
      Offset(right - cutSize, bottom),
      radius: const Radius.circular(cutSize),
      clockwise: true,
    );

    // 右下
    scanPath.lineTo(left + cutSize, bottom);
    scanPath.arcToPoint(
      Offset(left, bottom - cutSize),
      radius: const Radius.circular(cutSize),
      clockwise: true,
    );

    // 左下
    scanPath.lineTo(left, top + cutSize);
    scanPath.arcToPoint(
      Offset(left + cutSize, top),
      radius: const Radius.circular(cutSize),
      clockwise: true,
    );

    scanPath.close();

    // 使用 Path.combine 实现挖空中间区域
    return Path.combine(
      PathOperation.difference,
      path,
      scanPath,
    );
  }
}
