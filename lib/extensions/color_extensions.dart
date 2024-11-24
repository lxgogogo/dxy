import 'dart:io';
import 'dart:ui';

import 'package:holdem/extensions/int_extensions.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(String hexColor) : super(_getColorFromHex(hexColor));
}

extension HexString on Color? {
  String get hexStr {
    if (this == null) return '';
    if (Platform.isIOS) {
      return this!.red.toHex +
          this!.green.toHex +
          this!.blue.toHex +
          this!.alpha.toHex;
    } else if (Platform.isAndroid) {
      return "#${this!.alpha.toHex}${this!.red.toHex}${this!.green.toHex}${this!.blue.toHex}";
    }
    return '';
  }
}
