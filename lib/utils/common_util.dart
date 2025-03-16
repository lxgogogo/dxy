import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:flutter/rendering.dart';

double safeToDouble(dynamic value, {int limit = 3}) {
  if (value == null) return 0.toDouble();
  if (value is! num) return 0.toDouble();
  return value.toDouble();
}

String getFourBit(String? value) {
  if (value == null || value.isEmpty) return '';
  if (value.length <= 4) return value;
  return '${value.substring(0, 4)}...';
}

String truncateText(String text, int maxLength) {
  if (text.characters.length <= maxLength) {
    return text;
  }

  return "${String.fromCharCodes(
    text.characters.take(maxLength).map((char) => char.codeUnitAt(0)),
  )}...";
}

///获取字符串长度，中文2个字符，其他为1个字符
int getStringLen(String text) {
  int count = 0;
  count = text.runes.fold(0, (count, charCode) {
    String char = String.fromCharCode(charCode);
    if (isFullWidthCharacter(char) || isEmojis(char)) {
      return count + 2; // 中文字符和全角字符算两个字符长度
    } else {
      return count + 1; // 其他字符算一个字符长度
    }
  });
  // for (int i = 0; i < text.length; i++) {
  //   // DzLogger.i(">>>>>>getStringLen ${text[i]} ${text.codeUnitAt(i)}");
  //   if (text.codeUnitAt(i) > 122) {
  //     count += 2;
  //   } else {
  //     count += 1;
  //   }
  // }
  return count;
}

String substringWithPixelLength(String text, double totalLength, TextStyle style) {
  double currentWidth = getTextWidth(".", style) * 2; //two comma occupy space
  String result = "";

  var runes = text.runes;
  for (int current in runes) {
    String character = String.fromCharCode(current);
    double charWidth = getTextWidth(character, style); // 根据实际字符计算宽度
    currentWidth += charWidth;
    if (currentWidth >= totalLength) break;
    result = result + character;
  }
  return "$result..";
}

double getTextWidth(String text, TextStyle style) {
  TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr);
  textPainter.layout();
  return textPainter.width;
}

///擷取字符串,中文算1，其他字符算 0.5
String subString(String text, int num) {
  int endIndx = 0;
  int count = 0;
  int totalNum = num * 2;
  int i = 0;
  count = text.runes.fold(0, (count, charCode) {
    String char = String.fromCharCode(charCode);
    if (isFullWidthCharacter(char) || isEmojis(char)) {
      count += 2; // 中文字符和全角字符算两个字符长度
    } else {
      count += 1; // 其他字符算一个字符长度
    }
    if (endIndx == 0 && count >= totalNum) {
      endIndx = i;
    }
    i += 1;
    return count;
  });
  // for (int i = 0; i < text.length; i++) {
  //   if (text.codeUnitAt(i) > 122) {
  //     count += 2;
  //   } else {
  //     count += 1;
  //   }
  //   if (count >= totalNum) {
  //     endIndx = i;
  //     break;
  //   }
  // }
  if (endIndx == 0) {
    if (text.length <= totalNum) {
      endIndx = text.length;
    } else {
      endIndx = totalNum;
    }
  }
  endIndx++;
  if (endIndx >= text.length) {
    endIndx = text.length;
  }
  return text.substring(0, endIndx);
}

// 判断字符是否为全角字符(中文属于全角的一类)
bool isFullWidthCharacter(String char) {
  // 全角字符的unicode编码范围为：[\uFF00-\uFFEF] 和 [\u4E00-\u9FA5]
  return RegExp(r'[\uFF00-\uFFEF\u4E00-\u9FA5]').hasMatch(char);
}

bool isEmojis(String char) {
  RegExp regex =
      new RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  bool isEmoje = regex.hasMatch(char);
  return isEmoje;
}

String safeSubstring(String input, int length) {
  int count = 0; // 已计数的字符数
  StringBuffer result = StringBuffer(); // 用于构建结果字符串
  int i = 0; // 字符串索引
  int cursor = 0;
  while (cursor < input.length && i < length) {
    String char = "";
    String sample = input[cursor];
    // 判断字符类型
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(sample)) {
      // 中文字符
      char = input[cursor];
      count += 1;
      cursor = count;
    } else if (RegExp(r'[a-zA-Z0-9]').hasMatch(sample) || RegExp(r'[!"#$%&()*+,\-./:;<=>?@[\\\]^_`{|}~]').hasMatch(sample)) {
      // 英文字符和标点符号
      char = input[cursor];
      count += 1;
      cursor = count;
    } else if (RegExp(r'[\u203C-\u3299\uD83C-\uDBFF\uD83E-\uDFFF]').hasMatch(sample)) {
      // 表情符号
      char = input.substring(cursor, cursor + 2);
      count += 2;
      cursor = count;
    } else {
      // 其他字符（如空格等），按1计数
      char = input[cursor];
      count += 1;
      cursor = count;
    }
    // 添加字符到结果
    result.write(char);
    i++;
  }

  return result.toString(); // 返回截取结果
}

int customGetStringLen(String input) {
  StringBuffer result = StringBuffer(); // 用于构建结果字符串
  int i = 0; // 字符串索引
  int cursor = 0;
  while (cursor < input.length) {
    String sample = input[cursor];
    // 判断字符类型
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(sample)) {
      // 中文字符 //经过测试中文字符只占1位。测试平台：Android
      cursor += 1;
    } else if (RegExp(r'[a-zA-Z0-9]').hasMatch(sample) || RegExp(r'[!"#$%&()*+,\-./:;<=>?@[\\\]^_`{|}~]').hasMatch(sample)) {
      // 英文字符和标点符号
      cursor += 1;
    } else if (RegExp(r'[\u203C-\u3299\uD83C-\uDBFF\uD83E-\uDFFF]').hasMatch(sample)) {
      // 表情符号
      cursor += 2;
    } else {
      // 其他字符（如空格等），按1计数
      cursor += 1;
    }
    i++;
  }
  return i; // 返回截取结果
}

// 截取字符，并且判断全角模式
int getFullWidthTextIndex(String text, int maxLength) {
  int length = 0;
  int index = 0;

  for (var rune in text.runes) {
    String character = String.fromCharCode(rune);
    if (isFullWidthCharacter(character) || isEmojis(character)) {
      length += 2; // 中文或全角
    } else {
      length += 1;
    }
    // length += character.
    if (length > maxLength) {
      break;
    }
    index++;
  }

  return index;
}

String removeDecimalIfNeeded(String formattedNumber) {
  if (formattedNumber.contains('.')) {
    final v = formattedNumber.substring(0, formattedNumber.length - 1);
    if (formattedNumber.endsWith('.')) {
      return v;
    }
    if (formattedNumber.endsWith('0')) {
      return removeDecimalIfNeeded(v);
    }
  }
  return formattedNumber;
}

String formattedNumber(double number, {int d = 2}) {
  String formatted = number.toStringAsFixed(d);
  formatted = formatted.replaceAll(RegExp(r"0*$"), "");
  formatted = formatted.replaceAll(RegExp(r"\.$"), "");
  return formatted;
}

///盲注格式化
String scoreFormat(String? score) {
  if ((score?.length ?? 0) < 4) {
    return score.toString();
  } else if ((score?.length ?? 0) < 7) {
    return "${(double.tryParse(score ?? "") ?? 0) / 1000}K";
  } else {
    return "${(double.tryParse(score ?? "") ?? 0) / 1000000}M";
  }
}

//
extension SafeListAccess<T> on List<T> {
  // 通过下标安全获取元素
  T? getOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}
