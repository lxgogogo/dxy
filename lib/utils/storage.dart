
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  StorageUtil._internal();

  static final StorageUtil _instance = StorageUtil._internal();

  factory StorageUtil(){
    return _instance;
  }

  SharedPreferences? prefs;
  Future<void> init() async{
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setJSON(String key,var jsonVal){
    String jsonString = jsonEncode(jsonVal);
    return prefs!.setString(key, jsonString);
  }

  getJSON(String key){
    String? jsonString = prefs?.getString(key);
    return jsonString == null?null:jsonDecode(jsonString);
  }

  Future<bool> setBool(String key,bool value){
    return prefs!.setBool(key, value);
  }

  bool? getBool(String key){
    return prefs!.getBool(key);
  }

  Future<bool> remove(String key){
    return prefs!.remove(key);
  }
}