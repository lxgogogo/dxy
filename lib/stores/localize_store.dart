import 'dart:ui';

import 'package:get/get.dart';
import 'package:holdem/stores/storage.dart';

import '../i18n/d_pokers_i18n.dart';

class LocalizeStore extends GetxController {
  static LocalizeStore get of => Get.find();

  Locale get locale => _locale;
  Locale _locale = Get.locale ?? DPokersI18n.fallback;

  List<Locale> languages = DPokersI18n.supported;

  final Map<String, String> languageNameMap = DPokersI18n.languageNameMap;

  @override
  void onInit() {
    super.onInit();
    _initLanguage();
  }

  Future<void> _initLanguage() async {
    final result = StorageService.of.getLanguage();
    if (result.isEmpty) return;
    _locale = languages.firstWhere(
      (element) => element.languageCode == result,
      orElse: () => PlatformDispatcher.instance.locale,
    );
    await Get.updateLocale(_locale);
  }

  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    await Get.updateLocale(locale);
    await StorageService.of.putLanguage(locale.languageCode);
  }
}
