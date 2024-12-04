
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileUtil {
  static final LocalFileUtil of = LocalFileUtil._();
  LocalFileUtil._();

  Future<bool> writeImageDataToTemp({
    required List<int> bytes,
    required String fileName,
  }) async {
    final file = await _localTempFile(fileName: fileName);
    if (file == null) return false;
    try {
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<(bool exists, String filePath)> fileExistsFromTemp({
    required String fileName,
  }) async {
    final file = await _localTempFile(fileName: fileName);
    return (file?.existsSync() ?? false, file?.path ?? '');
  }

  Future<Uint8List?> readFileBytesFromTemp({
    required String fileName,
  }) async {
    final file = await _localTempFile(fileName: fileName);
    if (file != null && file.existsSync()) {
      return file.readAsBytes();
    }
    return null;
  }

  Future<void> deleteFileFromTemp({
    required String fileName,
  }) async {
    final file = await _localTempFile(fileName: fileName);
    if (file?.existsSync() == true) {
      file?.deleteSync();
    }
  }

  /// subDir：只在 windows 有用
  Future<bool> writeImageDataToDocument({
    required List<int> bytes,
    required String fileName,
    String subDir = '',
  }) async {
    final file = await localDocumentFile(
      fileName: fileName,
      subDir: subDir,
      create: true,
    );
    if (file == null) return false;
    try {
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// subDir：只在 windows 有用
  Future<Uint8List?> readFileBytesFromDocument({
    required String fileName,
    String subDir = '',
  }) async {
    final file = await localDocumentFile(
      fileName: fileName,
      subDir: subDir,
    );
    if (file != null && file.existsSync()) {
      return file.readAsBytes();
    }
    return null;
  }

  /// subDir：只在 windows 有用
  Future<void> deleteFileFromDocument({
    required String fileName,
    String subDir = '',
  }) async {
    final file = await localDocumentFile(
      fileName: fileName,
      subDir: subDir,
    );
    if (file?.existsSync() == true) {
      file?.deleteSync();
    }
  }
}

extension NativeLocalFileUtil on LocalFileUtil {
  Future<(bool exists, String filePath)> nativeAvatarFileExistsFromFileName({
    required String fileName,
  }) async {
    final path = await getApplicationDocumentsDirectory();
    final filePath = '${path.parent.path}/tmp/$fileName';
    final file = File(filePath);
    return (file.existsSync(), file.path);
  }
}

extension LocalFileUtilFilePath on LocalFileUtil {
  Future<String> localTempFilePath({
    required String fileName,
  }) async {
    final path = await getTemporaryDirectory();
    return '${path.path}/$fileName';
  }
}

extension LocalFileUtilPrivate on LocalFileUtil {
  Future<File?> _localTempFile({
    required String fileName,
  }) async {
    final path = await getTemporaryDirectory();
    final filePath = '${path.path}/$fileName';
    final file = File(filePath);
    return file;
  }

  Future<File?> localDocumentFile({
    required String fileName,
    String subDir = '',
    bool create = false,
  }) async {
    try {
      final dir = await localDocumentDir(
        subDir: subDir,
        create: create,
      );

      if (dir == null) return null;

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      if (file.existsSync() || create) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Directory?> localDocumentDir({
    String subDir = '',
    bool create = false,
  }) async {
    late Directory dir;
    dir = await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      if (create) {
        dir.createSync();
      } else {
        return null;
      }
    }
    return dir;
  }
}
