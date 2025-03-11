

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CodePointLengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  CodePointLengthLimitingTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (getCodePointLength(newValue.text) > maxLength) {
      return oldValue;
    }
    return newValue;
  }
  int getCodePointLength(String str) {
    if (str.codeUnits.isEmpty) {
      return str.length;
    }
    return str.characters.length;
  }
}