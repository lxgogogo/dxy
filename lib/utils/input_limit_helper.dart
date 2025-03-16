import 'dart:io';

import 'package:flutter/services.dart';
import 'package:holdem/utils/common_util.dart';

/// 自定义兼容中文拼音输入法正则校验输入框
class CustomizedTextInputFormatter extends TextInputFormatter {
  final Pattern? filterPattern;

  CustomizedTextInputFormatter({this.filterPattern}) : assert(filterPattern != null);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (Platform.isIOS && newValue.isComposingRangeValid) return newValue;
    return FilteringTextInputFormatter.allow(filterPattern!).formatEditUpdate(oldValue, newValue);
  }
}

/// 自定义兼容中文拼音输入法长度限制输入框
class CustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomizedLengthTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (Platform.isIOS) {
      if (newValue.isComposingRangeValid) return newValue;
    }

    return LengthLimitingTextInputFormatter(maxLength).formatEditUpdate(oldValue, newValue);
  }
}

// 昵称输入
class NickNameCustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  NickNameCustomizedLengthTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (Platform.isIOS) {
      if (newValue.isComposingRangeValid) return newValue;
    }
    int newLength = newValue.text.runes.fold(0, (count, charCode) {
      String char = String.fromCharCode(charCode);
      if (isFullWidthCharacter(char) || isEmojis(char)) {
        return count + 2; // 中文字符和全角字符算两个字符长度
      } else {
        return count + 1; // 其他字符算一个字符长度
      }
    });
    int subIndex = maxLength;
    if (newLength > maxLength) {
      // 如果超过最大长度，则截断文本
      subIndex = getFullWidthTextIndex(newValue.text, maxLength);
    }
    return LengthLimitingTextInputFormatter(subIndex).formatEditUpdate(oldValue, newValue);
  }
}
