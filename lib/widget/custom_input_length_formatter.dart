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
    return str.codeUnits.map((unit) => unit < 0xD800 || unit > 0xDFFF ? 1 : 2).reduce((value, element) => value + element);
  }
}