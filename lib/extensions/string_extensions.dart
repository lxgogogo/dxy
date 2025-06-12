import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:holdem/extensions/color_extensions.dart';

extension HexStringToColor on String {
  Color get hexColor => HexColor(this);
}

extension StringToMD5String on String {
  String get generateMD5 {
    final Uint8List content = const Utf8Encoder().convert(this);
    final Digest digest = md5.convert(content);
    return digest.toString();
  }
}

extension UrlParametersString on String? {
  String queryParametersOf(String key) {
    if (this?.isNotEmpty == true) {
      try {
        final uri = Uri.parse(this!);
        final queryParameters = uri.queryParameters;
        String value = queryParameters[key] ?? '';
        if (value.isEmpty) {
          // 解决 url 包含 # 号的特殊情况
          final fragment = uri.fragment;
          if (fragment.isNotEmpty) {
            value = fragment.queryParametersOf(key);
          }
        }
        return value;
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  Map<String, String>? queryParameters() {
    if (this?.isNotEmpty == true) {
      try {
        final uri = Uri.parse(this!);
        return uri.queryParameters;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}


extension SourceTypeExt on String? {
  String get sourceTypeDesc {
    if (this == 'thread') {
      return '帖子';
    } else if (this == 'article') {
      return '资讯';
    } else if (this == 'video') {
      return '视频';
    } else if (this == 'videoList') {
      return '视频合集';
    } else if (this == 'book') {
      return '书籍';
    } else if (this == 'tool') {
      return '工具';
    }
    return '资源';
  } 
}