import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/utils/local_file_util.dart';

class StorageService extends GetxService {
  static StorageService get of => Get.find();

  // late final SharedPreferences _prefs;
  late final Box _box;

  late Directory _docDir;

  Future<StorageService> init() async {
    try {
      final dir = await LocalFileUtil.of.localDocumentDir();
      if (dir != null) {
        _docDir = dir;
        Hive.init(_docDir.path);
        _box = await Hive.openBox('DeXueYuan');
        // _prefs = await SharedPreferences.getInstance();
      }
    } catch (e) {}
    return this;
  }
}

extension StorageServiceHive on StorageService {
  // 主题
  int getThemeIndex() {
    return _box.get(Constants.localTheme, defaultValue: 0);
  }

  Future<bool> putThemeIndex(int value) async {
    return _put(Constants.localTheme, value);
  }

  // 语言
  String getLanguage() {
    return _box.get(
      Constants.localLanguage,
      defaultValue: '',
    );
  }

  Future<bool> putLanguage(String value) async {
    return _put(Constants.localLanguage, value);
  }

  // 是否已经同意使用 app，也可以用作判断 app 是否首次安装
  bool get getDidAgreeUseApp => _box.get(
        Constants.localDidAgreeUseApp,
        defaultValue: false,
      );

  // 是否同意使用 app
  Future<bool> putDidAgreeUseApp() async {
    return _put(Constants.localDidAgreeUseApp, true);
  }

  // 登录 token
  String getToken() {
    return _box.get(Constants.token, defaultValue: '');
  }

  Future<bool> putToken(String value) async {
    return _put(Constants.token, value);
  }

  // 用户信息
  String getLocalUserStr() {
    String userInfo = _box.get(Constants.localUser, defaultValue: '');
    return userInfo;
  }

  Future<bool> putLocalUserStr(String value) async {
    return _put(Constants.localUser, value);
  }


  Future<List<String>> getIgnoredVersions() async {
    final jsonStr = await _box.get(Constants.localIgnoredVersions);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return List<String>.from(jsonStr.decode(jsonStr));
    } catch (_) {
      return [];
    }
  }

  Future<void> addIgnoredVersion(String version) async {
    final versions = await getIgnoredVersions();
    if (!versions.contains(version)) {
      versions.add(version);
      await _box.put(Constants.localIgnoredVersions, json.encode(versions));
    }
  }

}

extension _StorageServicePrivate on StorageService {
  Future<bool> _put(String key, dynamic value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<T> _getList<T>(String key) {
    return List<T>.from(
      _box.get(key, defaultValue: []),
    );
  }

  Future<bool> _delete(String key) async {
    try {
      await _box.delete(key);
      return true;
    } catch (e) {
      return false;
    }
  }
}
