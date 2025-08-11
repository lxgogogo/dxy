import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../generated/locales.g.dart';

class DPokersI18n extends Translations {
  static const List<Locale> supported = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  static final Locale fallback = Get.locale ?? Get.deviceLocale ?? const Locale('zh', 'CN');

  static const Map<String, String> languageNameMap = {
    "en": "English",
    "zh": "简体中文",
  };

  @override
  Map<String, Map<String, String>> get keys => AppTranslation.translations;
}
