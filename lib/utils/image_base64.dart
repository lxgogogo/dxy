import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

class ImageBase64 {
  static Future<List<int>> compressAndConvertToBase64(String filePath) async {
    // 读取文件
    final File file = File(filePath);
    final img.Image? image = img.decodeImage(file.readAsBytesSync());

    // 压缩图片
    final img.Image resized = img.copyResize(image!, width: 300); // 你可以调整尺寸

    // 转换为jpg格式（这通常会减小文件大小）
    final List<int> jpg = img.encodeJpg(resized, quality: 80); // 你可以调整质量

    // 转换为Base64
    final String base64String = base64Encode(jpg);

    return jpg;
  }

// 这个函数接收Base64编码的字符串，解码并返回一个ImageProvider
  static Future<ImageProvider> decodeFromBase64(String base64String) async {
    // 将Base64字符串解码为字节数据
    final Uint8List bytes = base64Decode(base64String);
    // 创建一个ImageProvider从内存
    return MemoryImage(bytes);
  }
}
